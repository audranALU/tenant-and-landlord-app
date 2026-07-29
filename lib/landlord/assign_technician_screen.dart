import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/landlord_provider.dart';

class AssignTechnicianScreen extends StatefulWidget {
  final String requestId;

  const AssignTechnicianScreen({super.key, required this.requestId});

  @override
  State<AssignTechnicianScreen> createState() => _AssignTechnicianScreenState();
}

class _AssignTechnicianScreenState extends State<AssignTechnicianScreen> {
  String? _selectedTechnicianId;
  String? _selectedTechnicianName;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    // Refresh technician list when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LandlordProvider>(context, listen: false)
          .refreshTechnicians();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Assign Technician"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LandlordProvider>(
        builder: (context, provider, _) {
          final technicians = provider.technicians;

          return Column(
            children: [
              // ── Header Info ──
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Select a technician to assign to this maintenance request.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Technician List ──
              Expanded(
                child: technicians.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: technicians.length,
                        itemBuilder: (context, index) {
                          final tech = technicians[index];
                          return _buildTechnicianTile(tech);
                        },
                      ),
              ),

              // ── Assign Button ──
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedTechnicianId == null || _isAssigning
                        ? null
                        : () => _assignTechnician(context, provider),
                    icon: _isAssigning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isAssigning ? "Assigning..." : "Assign Technician",
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTechnicianTile(Map<String, dynamic> tech) {
    final isSelected = _selectedTechnicianId == tech["uid"];
    final name = tech["name"] ?? "Unknown";
    final email = tech["email"] ?? "";
    // Get initials from name
    final initials = name
        .split(" ")
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : "")
        .take(2)
        .join();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTechnicianId = tech["uid"];
          _selectedTechnicianName = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // Check icon
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "No Technicians Available",
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "There are no technicians registered in the system yet. Technicians need to create an account with the technician role.",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignTechnician(
    BuildContext context,
    LandlordProvider provider,
  ) async {
    if (_selectedTechnicianId == null || _selectedTechnicianName == null) return;

    setState(() => _isAssigning = true);

    final success = await provider.assignTechnician(
      widget.requestId,
      _selectedTechnicianId!,
      _selectedTechnicianName!,
    );

    if (context.mounted) {
      setState(() => _isAssigning = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$_selectedTechnicianName has been assigned",
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to assign technician"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

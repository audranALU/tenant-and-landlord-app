import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/status_badge.dart';
import '../models/maintenance_request_model.dart';
import '../providers/landlord_provider.dart';
import 'assign_technician_screen.dart';

class RequestDetailScreen extends StatelessWidget {
  final MaintenanceRequestModel request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // Listen for real-time updates to this specific request
    return Consumer<LandlordProvider>(
      builder: (context, provider, _) {
        // Find the latest version of this request from the provider
        final updatedRequest = provider.allRequests.firstWhere(
          (r) => r.id == request.id,
          orElse: () => request,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text("Request Details"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) =>
                    _handleMenuAction(context, provider, updatedRequest, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: "change_status",
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, size: 20),
                        SizedBox(width: 10),
                        Text("Change Status"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "change_priority",
                    child: Row(
                      children: [
                        Icon(Icons.flag_rounded, size: 20),
                        SizedBox(width: 10),
                        Text("Change Priority"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Main Info Card ──
                _buildInfoCard(updatedRequest),

                const SizedBox(height: 16),

                // ── Details Grid ──
                _buildDetailsGrid(updatedRequest),

                const SizedBox(height: 16),

                // ── Description Card ──
                _buildDescriptionCard(updatedRequest),

                const SizedBox(height: 16),

                // ── Photo Card ──
                if (updatedRequest.imageUrl.isNotEmpty)
                  _buildPhotoCard(updatedRequest),

                if (updatedRequest.imageUrl.isNotEmpty)
                  const SizedBox(height: 16),

                // ── Technician Assignment Card ──
                _buildTechnicianCard(context, provider, updatedRequest),

                const SizedBox(height: 24),

                // ── Action Buttons ──
                _buildActionButtons(context, provider, updatedRequest),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Main Info Card ──
  Widget _buildInfoCard(MaintenanceRequestModel req) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _categoryColor(req.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _categoryIcon(req.category),
              color: _categoryColor(req.category),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${req.category} Issue",
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  req.location,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(status: req.status),
                    const SizedBox(width: 10),
                    PriorityIndicator(
                      priority: req.urgency,
                      showLabel: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Details Grid ──
  Widget _buildDetailsGrid(MaintenanceRequestModel req) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  "Category",
                  req.category,
                  Icons.category_rounded,
                ),
              ),
              Expanded(
                child: _detailItem(
                  "Location",
                  req.location,
                  Icons.location_on_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _detailItem(
                  "Reported",
                  _formatDate(req.createdAt),
                  Icons.calendar_today_rounded,
                ),
              ),
              Expanded(
                child: _detailItem(
                  "Status",
                  _statusLabel(req.status),
                  Icons.info_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelUppercase,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Description Card ──
  Widget _buildDescriptionCard(MaintenanceRequestModel req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DESCRIPTION",
            style: AppTextStyles.labelUppercase,
          ),
          const SizedBox(height: 8),
          Text(
            req.description,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Photo Card ──
  Widget _buildPhotoCard(MaintenanceRequestModel req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ATTACHED PHOTO",
            style: AppTextStyles.labelUppercase,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              req.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: AppColors.primaryLight,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stack) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Unable to load image",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Technician Card ──
  Widget _buildTechnicianCard(
    BuildContext context,
    LandlordProvider provider,
    MaintenanceRequestModel req,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TECHNICIAN ASSIGNMENT",
            style: AppTextStyles.labelUppercase,
          ),
          const SizedBox(height: 12),
          if (req.status == "assigned" || req.status == "in_progress")
            // Show assigned technician
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assigned Technician",
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Technician assigned",
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToAssign(context),
                  child: const Text("Reassign"),
                ),
              ],
            )
          else
            // Show assign button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _navigateToAssign(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text("Assign Technician"),
              ),
            ),
        ],
      ),
    );
  }

  // ── Action Buttons ──
  Widget _buildActionButtons(
    BuildContext context,
    LandlordProvider provider,
    MaintenanceRequestModel req,
  ) {
    // Show contextual actions based on current status
    if (req.status == "resolved" || req.status == "completed") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.resolvedBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.resolvedText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "This request has been resolved",
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600).copyWith(
                color: AppColors.resolvedText,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (req.status == "open") ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToAssign(context),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text("Assign & Start"),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (req.status == "assigned") ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(
                context,
                provider,
                req.id,
                "in_progress",
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text("Mark In Progress"),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (req.status == "in_progress") ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(
                context,
                provider,
                req.id,
                "resolved",
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text("Mark Resolved"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showStatusPicker(context, provider, req),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text("Change Status"),
          ),
        ),
      ],
    );
  }

  // ── Navigation ──
  void _navigateToAssign(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignTechnicianScreen(requestId: request.id),
      ),
    );
  }

  // ── Actions ──
  Future<void> _updateStatus(
    BuildContext context,
    LandlordProvider provider,
    String requestId,
    String newStatus,
  ) async {
    final success = await provider.updateStatus(requestId, newStatus);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Status updated to ${_statusLabel(newStatus)}"
                : "Failed to update status",
          ),
        ),
      );
    }
  }

  void _handleMenuAction(
    BuildContext context,
    LandlordProvider provider,
    MaintenanceRequestModel req,
    String action,
  ) {
    if (action == "change_status") {
      _showStatusPicker(context, provider, req);
    } else if (action == "change_priority") {
      _showPriorityPicker(context, provider, req);
    }
  }

  // ── Status Picker Bottom Sheet ──
  void _showStatusPicker(
    BuildContext context,
    LandlordProvider provider,
    MaintenanceRequestModel req,
  ) {
    final statuses = ["open", "assigned", "in_progress", "resolved"];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Change Status", style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ...statuses.map((status) {
                final isActive = req.status == status;
                return ListTile(
                  onTap: isActive
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _updateStatus(
                            context,
                            provider,
                            req.id,
                            status,
                          );
                        },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: StatusBadge(status: status),
                  trailing: isActive
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ── Priority Picker Bottom Sheet ──
  void _showPriorityPicker(
    BuildContext context,
    LandlordProvider provider,
    MaintenanceRequestModel req,
  ) {
    final priorities = [
      {"id": "low", "color": AppColors.priorityLow},
      {"id": "medium", "color": AppColors.priorityMedium},
      {"id": "high", "color": AppColors.priorityHigh},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Change Priority", style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ...priorities.map((p) {
                final id = p["id"] as String;
                final color = p["color"] as Color;
                final isActive = req.urgency.toLowerCase() == id;

                return ListTile(
                  onTap: isActive
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          final success = await provider.updatePriority(
                            req.id,
                            id,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "Priority changed to $id"
                                      : "Failed to update priority",
                                ),
                              ),
                            );
                          }
                        },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${id[0].toUpperCase()}${id.substring(1)} Priority",
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  trailing: isActive
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ──
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    try {
      final date = timestamp.toDate();
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    } catch (_) {
      return "N/A";
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "open":
        return "Open";
      case "assigned":
        return "Assigned";
      case "in_progress":
        return "In Progress";
      case "resolved":
        return "Resolved";
      default:
        return status;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "plumbing":
        return Icons.plumbing_rounded;
      case "electrical":
        return Icons.electrical_services_rounded;
      case "structural":
        return Icons.foundation_rounded;
      case "pest":
      case "pest control":
        return Icons.pest_control_rounded;
      case "appliance":
      case "appliances":
        return Icons.kitchen_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case "plumbing":
        return AppColors.info;
      case "electrical":
        return AppColors.warning;
      case "structural":
        return const Color(0xFF8B5CF6);
      case "pest":
      case "pest control":
        return AppColors.error;
      case "appliance":
      case "appliances":
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/maintenance_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  String _urgency = "medium";
  File? _pickedImage;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {"id": "plumbing", "icon": Icons.plumbing_rounded, "label": "Plumbing"},
    {"id": "electrical", "icon": Icons.electrical_services_rounded, "label": "Electrical"},
    {"id": "structural", "icon": Icons.foundation_rounded, "label": "Structural"},
    {"id": "pest", "icon": Icons.pest_control_rounded, "label": "Pest Control"},
    {"id": "appliance", "icon": Icons.kitchen_rounded, "label": "Appliances"},
    {"id": "other", "icon": Icons.build_rounded, "label": "Other"},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  bool get _isValid =>
      _selectedCategory != null &&
      _descriptionController.text.trim().isNotEmpty &&
      _locationController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = Provider.of<MaintenanceProvider>(context, listen: false);

    // NOTE: image upload to Firebase Storage is left for integration.
    // For now we save an empty imageUrl. Wire up FirebaseStorage upload here
    // and pass the resulting download URL as imageUrl.
    final success = await provider.createRequest(
      category: _selectedCategory!,
      urgency: _urgency,
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: "",
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request submitted successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to submit request"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Report an Issue"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            _buildCategoryGrid(),
            const SizedBox(height: 24),

            Text("Description", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Describe the issue in detail...",
              ),
            ),
            const SizedBox(height: 24),

            Text("Location", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "e.g. Kitchen, Bathroom, Bedroom",
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 24),

            Text("Urgency Level", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            _buildUrgencySelector(),
            const SizedBox(height: 24),

            Text("Photo (Optional)", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            _buildImagePicker(),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit Report"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final isSelected = _selectedCategory == cat["id"];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat["id"]),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat["icon"],
                  size: 28,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                Text(
                  cat["label"],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUrgencySelector() {
    final levels = [
      {"id": "low", "color": AppColors.priorityLow},
      {"id": "medium", "color": AppColors.priorityMedium},
      {"id": "high", "color": AppColors.priorityHigh},
    ];
    return Row(
      children: levels.map((level) {
        final id = level["id"] as String;
        final color = level["color"] as Color;
        final isSelected = _urgency == id;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _urgency = id),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${id[0].toUpperCase()}${id.substring(1)}",
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    if (_pickedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              _pickedImage!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _pickedImage = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              "Tap to add a photo",
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

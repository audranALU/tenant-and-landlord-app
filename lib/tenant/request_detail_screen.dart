import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/status_badge.dart';
import '../models/maintenance_request_model.dart';
import '../providers/maintenance_provider.dart';
import 'edit_request_screen.dart';

class RequestDetailScreen extends StatelessWidget {
  final MaintenanceRequestModel request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Request Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tenants can only edit/cancel while the request is still open
          if (request.status == "open")
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) => _handleAction(context, value),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 20),
                      SizedBox(width: 10),
                      Text("Edit Request"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "cancel",
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                      SizedBox(width: 10),
                      Text("Cancel Request", style: TextStyle(color: AppColors.error)),
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
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildDescriptionCard(),
            if (request.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPhotoCard(),
            ],
            const SizedBox(height: 16),
            _buildStatusInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
              color: _categoryColor(request.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _categoryIcon(request.category),
              color: _categoryColor(request.category),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${request.category} Issue", style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(request.location, style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(status: request.status),
                    const SizedBox(width: 10),
                    PriorityIndicator(priority: request.urgency, showLabel: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
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
          Text("DESCRIPTION", style: AppTextStyles.labelUppercase),
          const SizedBox(height: 8),
          Text(
            request.description,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
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
          Text("ATTACHED PHOTO", style: AppTextStyles.labelUppercase),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              request.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 200,
                color: AppColors.primaryLight,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage(request.status),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _statusMessage(String status) {
    switch (status) {
      case "open":
        return "Your request has been submitted and is awaiting review by your landlord.";
      case "assigned":
        return "A technician has been assigned to your request.";
      case "in_progress":
        return "Work on your request is currently in progress.";
      case "resolved":
        return "This request has been resolved. Thank you!";
      default:
        return "Request status: $status";
    }
  }

  void _handleAction(BuildContext context, String action) {
    if (action == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditRequestScreen(request: request),
        ),
      );
    } else if (action == "cancel") {
      _confirmCancel(context);
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Request?"),
        content: const Text(
          "Are you sure you want to cancel this maintenance request? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Keep"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider =
                  Provider.of<MaintenanceProvider>(context, listen: false);
              final success = await provider.deleteRequest(request.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? "Request cancelled" : "Failed to cancel request",
                    ),
                  ),
                );
                if (success) Navigator.pop(context);
              }
            },
            child: const Text("Cancel Request", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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

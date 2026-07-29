import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.badge.copyWith(
          color: config.textColor,
        ),
      ),
    );
  }

  static _BadgeConfig _getConfig(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return _BadgeConfig(
          label: 'Open',
          background: AppColors.openBg,
          textColor: AppColors.openText,
        );
      case 'in_progress':
        return _BadgeConfig(
          label: 'In Progress',
          background: AppColors.inProgressBg,
          textColor: AppColors.inProgressText,
        );
      case 'assigned':
        return _BadgeConfig(
          label: 'Assigned',
          background: AppColors.assignedBg,
          textColor: AppColors.assignedText,
        );
      case 'resolved':
      case 'completed':
        return _BadgeConfig(
          label: 'Resolved',
          background: AppColors.resolvedBg,
          textColor: AppColors.resolvedText,
        );
      default:
        return _BadgeConfig(
          label: status,
          background: AppColors.assignedBg,
          textColor: AppColors.assignedText,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color background;
  final Color textColor;

  _BadgeConfig({
    required this.label,
    required this.background,
    required this.textColor,
  });
}

class PriorityIndicator extends StatelessWidget {
  final String priority;
  final bool showLabel;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(priority);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            '${priority[0].toUpperCase()}${priority.substring(1)} Priority',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }

  static Color _getColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.textSecondary;
    }
  }
}

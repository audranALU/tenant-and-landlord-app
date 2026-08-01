import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Reusable bottom navigation bar matching the design across
/// Home / Tickets / Alerts / Profile.
class BottomNavBar extends StatelessWidget {
  final int currentIndex; // 0 = Home, 1 = Tickets, 2 = Alerts, 3 = Profile
  final ValueChanged<int>? onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(icon: Icons.home_outlined, label: 'Home'),
      _NavItemData(icon: Icons.assignment_outlined, label: 'Tickets'),
      _NavItemData(icon: Icons.notifications_none_rounded, label: 'Alerts'),
      _NavItemData(icon: Icons.person_outline, label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap?.call(index),
                behavior: HitTestBehavior.opaque,
                child: isSelected
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon,
                                color: Colors.black87, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  _NavItemData({required this.icon, required this.label});
}

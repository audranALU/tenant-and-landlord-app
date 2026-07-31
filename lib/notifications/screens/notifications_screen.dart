import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = <AppNotification>[
      AppNotification(
        id: '1',
        title: 'Maintenance update',
        body: 'Your request has been updated and is now in progress.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        read: false,
        type: 'status',
        metadata: const {},
        icon: 'build',
      ),
      AppNotification(
        id: '2',
        title: 'Payment received',
        body: 'Your rent payment was successfully processed.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        read: true,
        type: 'info',
        metadata: const {},
        icon: 'payment',
      ),
      AppNotification(
        id: '3',
        title: 'System alert',
        body: 'Scheduled maintenance will occur tonight at 10 PM.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        read: false,
        type: 'alert',
        metadata: const {},
        icon: 'alert',
      ),
    ];

    final grouped = NotificationService.instance.groupByDay(notifications);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            ...entry.value.map((notification) {
              final unread = !notification.read;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: unread
                      ? const Border(left: BorderSide(color: AppColors.unreadBar, width: 4))
                      : null,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: unread ? AppColors.gold : const Color(0xFFE8E8E8),
                    child: Icon(
                      notification.type == 'alert'
                          ? Icons.warning_amber_rounded
                          : notification.type == 'status'
                              ? Icons.build_outlined
                              : Icons.notifications_none,
                      color: unread ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(notification.body),
                  ),
                  trailing: unread
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.unreadBar,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService.instance;
  List<AppNotification> _cached = [];
  bool _restoredCache = false;

  @override
  void initState() {
    super.initState();
    // Show cached data instantly (works offline / before the stream's
    // first snapshot arrives), then the StreamBuilder below takes over
    // as soon as Firestore responds.
    _service.restoreFromCache().then((cached) {
      if (!mounted) return;
      setState(() {
        _cached = cached;
        _restoredCache = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<AppNotification>>(
          stream: _service.streamNotifications(),
          builder: (context, snapshot) {
            // Prefer live data the moment it arrives; fall back to the
            // local cache while waiting on the first snapshot or offline.
            final notifications = snapshot.hasData
                ? snapshot.data!
                : (_restoredCache ? _cached : null);

            if (notifications == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final grouped = _service.groupByDay(notifications);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 8),
                for (final entry in grouped.entries) ...[
                  _SectionLabel(entry.key),
                  const SizedBox(height: 10),
                  ...entry.value.map((n) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _NotificationCard(
                          notification: n,
                          onTap: () => _service.markAsRead(n.id),
                        ),
                      )),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (i) {},
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Mark all as read'),
              onTap: () async {
                Navigator.pop(context);
                final current = snapshotOrCache();
                await _service.markAllAsRead(current);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<AppNotification> snapshotOrCache() => _cached;
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationCard({required this.notification, required this.onTap});

  /// Icon background/foreground per type, matching the original mockups
  /// (status updates get the gold circle, alerts get the red circle).
  (Color, Color) get _iconColors {
    switch (notification.type) {
      case NotificationType.statusUpdate:
        return (AppColors.gold, AppColors.textPrimary);
      case NotificationType.systemAlert:
        return (const Color(0xFFFBE0DC), AppColors.red);
      default:
        return (const Color(0xFFE7E7E5), Colors.black87);
    }
  }

  String get _timeLabel {
    final now = DateTime.now();
    final createdAt = notification.createdAt;
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final diff = now.difference(createdAt);

    if (day == today) {
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    final hour = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final dayLabel = day == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : '${createdAt.month}/${createdAt.day}';
    return '$dayLabel, $hour:$minute $period';
  }

  /// Renders the body text, with a highlighted status badge for
  /// status_update notifications (metadata['status'] set by the backend).
  List<InlineSpan> get _messageSpans {
    final status = notification.metadata['status'] as String?;
    if (notification.type == NotificationType.statusUpdate && status != null) {
      final parts = notification.body.split(status);
      return [
        TextSpan(text: parts.isNotEmpty ? parts.first : notification.body),
        TextSpan(
          text: status,
          style: const TextStyle(
            backgroundColor: AppColors.gold,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (parts.length > 1) TextSpan(text: parts.sublist(1).join(status)),
      ];
    }
    return [TextSpan(text: notification.body)];
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _iconColors;
    final unread = !notification.read;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
          border: unread
              ? const Border(
                  left: BorderSide(color: AppColors.unreadBar, width: 4))
              : null,
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(notification.icon, color: fg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _timeLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.unreadBar,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                      children: _messageSpans,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

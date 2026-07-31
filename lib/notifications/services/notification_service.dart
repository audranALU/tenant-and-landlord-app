class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Map<String, List<dynamic>> groupByDay(List<dynamic> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<dynamic>>{
      'TODAY': [],
      'YESTERDAY': [],
      'EARLIER': [],
    };

    for (final notification in notifications) {
      final createdAt = notification.createdAt as DateTime;
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      if (day == today) {
        grouped['TODAY']!.add(notification);
      } else if (day == yesterday) {
        grouped['YESTERDAY']!.add(notification);
      } else {
        grouped['EARLIER']!.add(notification);
      }
    }

    grouped.removeWhere((_, list) => list.isEmpty);
    return grouped;
  }
}

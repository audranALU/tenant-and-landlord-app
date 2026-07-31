class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String type;
  final Map<String, dynamic> metadata;
  final String icon;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    required this.type,
    required this.metadata,
    required this.icon,
  });
}

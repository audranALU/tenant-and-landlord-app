import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Notification "type" values written by Cloud Functions / backend triggers.
/// Keeping these as an enum avoids typos when querying/filtering.
enum NotificationType {
  message,
  statusUpdate,
  serviceScheduled,
  paymentConfirmed,
  systemAlert,
  unknown,
}

NotificationType notificationTypeFromString(String value) {
  switch (value) {
    case 'message':
      return NotificationType.message;
    case 'status_update':
      return NotificationType.statusUpdate;
    case 'service_scheduled':
      return NotificationType.serviceScheduled;
    case 'payment_confirmed':
      return NotificationType.paymentConfirmed;
    case 'system_alert':
      return NotificationType.systemAlert;
    default:
      return NotificationType.unknown;
  }
}

/// One notification document, mirroring `/notifications/{id}` in Firestore.
class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? ticketId;
  final DateTime createdAt;
  final bool read;
  final Map<String, dynamic> metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.ticketId,
    this.read = false,
    this.metadata = const {},
  });

  factory AppNotification.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: notificationTypeFromString(data['type'] ?? ''),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      ticketId: data['ticketId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Used when caching to SharedPreferences (JSON-encodable, no Timestamp).
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'ticketId': ticketId,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
        'metadata': metadata,
      };

  factory AppNotification.fromCacheJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      type: notificationTypeFromString(json['type'] ?? ''),
      title: json['title'],
      body: json['body'],
      ticketId: json['ticketId'],
      createdAt: DateTime.parse(json['createdAt']),
      read: json['read'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      ticketId: ticketId,
      createdAt: createdAt,
      read: read ?? this.read,
      metadata: metadata,
    );
  }

  /// Icon + colors for the existing NotificationsScreen UI, kept here so
  /// design decisions live next to the data they describe.
  IconData get icon {
    switch (type) {
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.statusUpdate:
        return Icons.assignment_outlined;
      case NotificationType.serviceScheduled:
        return Icons.calendar_today_outlined;
      case NotificationType.paymentConfirmed:
        return Icons.payments_outlined;
      case NotificationType.systemAlert:
        return Icons.warning_amber_rounded;
      case NotificationType.unknown:
        return Icons.notifications_none_rounded;
    }
  }

  bool get isAlert => type == NotificationType.systemAlert;
}

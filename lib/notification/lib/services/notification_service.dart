import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_notification.dart';
import 'preferences_service.dart';

/// Owns all reads/writes to the `notifications` collection and keeps the
/// SharedPreferences cache (via PreferencesService) in sync so the UI has
/// something to render instantly and offline.
///
/// Notification documents are created server-side only (see
/// firebase/functions/index.js) — the client just listens, marks-as-read,
/// and deletes its own notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _firestore = FirebaseFirestore.instance;
  final _prefs = PreferencesService.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  /// Real-time stream of the current user's notifications, newest first.
  /// Every emission is also mirrored into SharedPreferences so
  /// `restoreCachedNotifications()` has fresh data for the next cold start.
  Stream<List<AppNotification>> streamNotifications({int limit = 50}) {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _collection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final notifications =
          snapshot.docs.map(AppNotification.fromFirestore).toList();

      // Fire-and-forget: keep the local cache warm for offline/instant load.
      _prefs.cacheNotifications(notifications);
      _prefs.setUnreadCount(notifications.where((n) => !n.read).length);

      return notifications;
    });
  }

  /// Use on app start / before the Firestore stream has its first emission,
  /// so the notifications list isn't empty for a beat.
  Future<List<AppNotification>> restoreFromCache() {
    return _prefs.restoreCachedNotifications();
  }

  Future<int> cachedUnreadCount() => _prefs.getUnreadCount();

  Future<void> markAsRead(String notificationId) async {
    await _collection.doc(notificationId).update({'read': true});
  }

  Future<void> markAllAsRead(List<AppNotification> current) async {
    final batch = _firestore.batch();
    for (final n in current.where((n) => !n.read)) {
      batch.update(_collection.doc(n.id), {'read': true});
    }
    await batch.commit();
  }

  Future<void> delete(String notificationId) async {
    await _collection.doc(notificationId).delete();
  }

  /// Splits a notification list into Today / Yesterday / Earlier buckets,
  /// matching the section headers already built into NotificationsScreen.
  Map<String, List<AppNotification>> groupByDay(
      List<AppNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<AppNotification>>{
      'TODAY': [],
      'YESTERDAY': [],
      'EARLIER': [],
    };

    for (final n in notifications) {
      final day = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (day == today) {
        grouped['TODAY']!.add(n);
      } else if (day == yesterday) {
        grouped['YESTERDAY']!.add(n);
      } else {
        grouped['EARLIER']!.add(n);
      }
    }

    grouped.removeWhere((_, list) => list.isEmpty);
    return grouped;
  }
}

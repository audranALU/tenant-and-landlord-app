import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level (not inside a class) background handler — required by the
/// firebase_messaging plugin since it runs in a separate isolate.
/// Register it in main.dart with:
///   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firestore listeners (NotificationService) pick up the new document once
  // the app is reopened/foregrounded, so nothing else to do here — this
  // exists mainly so background pushes are delivered instead of dropped.
}

/// Wires Firebase Cloud Messaging to the app:
/// - Requests notification permission (iOS/Android 13+)
/// - Grabs the device token and stores it on users/{uid}.fcmTokens
/// - Shows a local heads-up notification when a push arrives in foreground
/// - Exposes a stream for "user tapped a push" so you can route to
///   NotificationsScreen or a specific ticket
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications',
    description: 'Ticket, payment, and system alerts',
    importance: Importance.high,
  );

  Future<void> initialize({
    required void Function(RemoteMessage message) onMessageTapped,
  }) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await _registerToken();
    _messaging.onTokenRefresh.listen(_saveToken);

    // App in foreground: show a local banner (FCM doesn't auto-display
    // notifications while the app is open).
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    // App backgrounded and user taps the system notification.
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageTapped);

    // App was fully killed and opened via tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) onMessageTapped(initialMessage);
  }

  Future<void> _registerToken() async {
    // iOS simulators don't support APNs; guard so this doesn't throw in dev.
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) return;
    }
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  /// Call on logout so the old device stops receiving this user's pushes.
  Future<void> unregisterToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final token = await _messaging.getToken();
    if (uid == null || token == null) return;
    await _firestore.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayRemove([token]),
    }, SetOptions(merge: true));
  }
}

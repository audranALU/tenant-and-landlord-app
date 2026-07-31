import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/app_notification.dart';

/// Everything that touches SharedPreferences lives here so no other file
/// needs to know the storage keys or JSON shape.
///
/// Two jobs:
/// 1. Instant local read/write of the Settings screen toggles (so the UI
///    doesn't flash defaults while Firestore loads), synced to Firestore
///    in the background by NotificationService/ProfileService.
/// 2. A local cache of the most recent notifications + unread count, so
///    NotificationsScreen has something to show immediately on cold start
///    or while offline, before the Firestore stream catches up.
class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  static const _kSettings = 'app_settings';
  static const _kCachedNotifications = 'cached_notifications';
  static const _kUnreadCount = 'unread_count';
  static const _kLastSyncedAt = 'last_synced_at';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------- Settings ----------

  Future<AppSettings> loadSettings() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kSettings);
    if (raw == null) return const AppSettings();
    return AppSettings.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(_kSettings, jsonEncode(settings.toMap()));
  }

  // ---------- Notification cache (for offline / instant restore) ----------

  Future<void> cacheNotifications(List<AppNotification> notifications) async {
    final prefs = await _prefs;
    final encoded =
        jsonEncode(notifications.map((n) => n.toCacheJson()).toList());
    await prefs.setString(_kCachedNotifications, encoded);
    await prefs.setString(_kLastSyncedAt, DateTime.now().toIso8601String());
  }

  Future<List<AppNotification>> restoreCachedNotifications() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kCachedNotifications);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => AppNotification.fromCacheJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DateTime?> getLastSyncedAt() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kLastSyncedAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  // ---------- Unread count (drives a badge without waiting on Firestore) ----------

  Future<void> setUnreadCount(int count) async {
    final prefs = await _prefs;
    await prefs.setInt(_kUnreadCount, count);
  }

  Future<int> getUnreadCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_kUnreadCount) ?? 0;
  }

  // ---------- Wipe on logout ----------

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.remove(_kSettings),
      prefs.remove(_kCachedNotifications),
      prefs.remove(_kUnreadCount),
      prefs.remove(_kLastSyncedAt),
    ]);
  }
}

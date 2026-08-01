import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_settings.dart';
import 'preferences_service.dart';

/// Backs SettingsScreen's four toggles.
///
/// Pattern: local-first. `load()` returns instantly from SharedPreferences
/// so the switches don't flicker on screen open; Firestore is then read in
/// the background and, if it disagrees (e.g. the user changed a setting on
/// another device), the local cache is refreshed via [syncFromRemote].
/// Every toggle write updates both local storage and Firestore.
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  final _firestore = FirebaseFirestore.instance;
  final _prefs = PreferencesService.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection('users').doc(_uid);

  Future<AppSettings> loadLocal() => _prefs.loadSettings();

  /// One-shot pull from Firestore, also refreshing the local cache.
  Future<AppSettings> syncFromRemote() async {
    final uid = _uid;
    if (uid == null) return _prefs.loadSettings();
    final doc = await _doc.get();
    final remote = AppSettings.fromMap(
        (doc.data() ?? {})['settings'] as Map<String, dynamic>?);
    await _prefs.saveSettings(remote);
    return remote;
  }

  Future<void> update(AppSettings settings) async {
    await _prefs.saveSettings(settings);
    if (_uid != null) {
      await _doc.set({'settings': settings.toMap()}, SetOptions(merge: true));
    }
  }
}

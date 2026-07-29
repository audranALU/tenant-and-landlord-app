/// Mirrors the four toggles on SettingsScreen. Persisted both locally
/// (SharedPreferences, for instant load + offline) and in Firestore
/// under users/{uid}.settings (so it's consistent across devices).
class AppSettings {
  final bool pushNotifications;
  final bool emailAlerts;
  final bool darkMode;
  final bool lowDataMode;

  const AppSettings({
    this.pushNotifications = true,
    this.emailAlerts = false,
    this.darkMode = false,
    this.lowDataMode = false,
  });

  Map<String, dynamic> toMap() => {
        'pushNotifications': pushNotifications,
        'emailAlerts': emailAlerts,
        'darkMode': darkMode,
        'lowDataMode': lowDataMode,
      };

  factory AppSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppSettings();
    return AppSettings(
      pushNotifications: map['pushNotifications'] ?? true,
      emailAlerts: map['emailAlerts'] ?? false,
      darkMode: map['darkMode'] ?? false,
      lowDataMode: map['lowDataMode'] ?? false,
    );
  }

  AppSettings copyWith({
    bool? pushNotifications,
    bool? emailAlerts,
    bool? darkMode,
    bool? lowDataMode,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      darkMode: darkMode ?? this.darkMode,
      lowDataMode: lowDataMode ?? this.lowDataMode,
    );
  }
}

# Notification UI + Firebase Backend

Flutter screens recreating the Profile, Settings, and Notifications (Alerts) designs,
backed by Cloud Firestore, SharedPreferences, and Cloud Messaging.
Built as a standalone module so it drops straight into a bigger group project —
no `main.dart` or app picker included, just the screens, services, and backend config.

**Start here:** [`FIREBASE_SETUP.md`](./FIREBASE_SETUP.md) — exact commands to
stand up Firestore, generate config files, and deploy rules/functions for
project `tenant-and-landlord-app-fad4c`.

## Structure
```
notification/
├── FIREBASE_SETUP.md                 # Step-by-step setup + deploy commands
├── pubspec.yaml                      # Reference only — merge deps into your team's pubspec
├── firebase/                         # Project-level Firebase config (not Dart)
│   ├── firestore.rules               # Security rules for users/ + notifications/
│   ├── firestore.indexes.json        # Composite index the notification query needs
│   ├── firebase.json / .firebaserc   # Points deploy commands at the project
│   └── functions/
│       ├── package.json
│       └── index.js                  # FCM push sender + example notification triggers
└── lib/
    ├── notification.dart             # Barrel file — import this to get everything
    ├── app_colors.dart                # Shared color constants
    ├── models/
    │   ├── app_notification.dart     # Notification doc <-> UI mapping
    │   ├── app_settings.dart         # Settings toggle state
    │   └── user_profile.dart         # Profile header/stats
    ├── services/
    │   ├── notification_service.dart # Firestore listeners + read/unread + grouping
    │   ├── preferences_service.dart  # SharedPreferences: settings + offline cache
    │   ├── settings_service.dart     # Local-first settings, synced to Firestore
    │   ├── profile_service.dart      # Profile stats read/write
    │   └── fcm_service.dart          # Push permission, token registration, foreground display
    ├── widgets/
    │   └── bottom_nav_bar.dart       # Reusable Home/Tickets/Alerts/Profile bar
    └── screens/
        ├── profile_screen.dart       # Avatar, stats, menu list, log out
        ├── settings_screen.dart      # Wired to SettingsService — toggles persist + sync
        └── notifications_screen.dart # Wired to NotificationService — live + offline
```

## Using it in your group project
1. Copy the `notification` folder into your team's `lib/` directory
   (e.g. `lib/notification/`).
2. Import the screens wherever you need them:
   ```dart
   import 'notification/notification.dart';

   Navigator.push(context, MaterialPageRoute(
     builder: (_) => const ProfileScreen(),
   ));
   ```
   Or import a single screen directly:
   ```dart
   import 'notification/screens/settings_screen.dart';
   ```
3. No extra dependencies are needed beyond plain `flutter` + `cupertino_icons`
   (already standard in most Flutter projects), so nothing extra to add to
   your team's `pubspec.yaml`.

## Notes
- `profile_screen.dart` uses a placeholder network image for the avatar —
  swap the `NetworkImage` for your own asset or user photo.
- All three screens share the same `BottomNavBar` widget so the selected tab
  stays visually consistent; wire up `onTap` to your team's real navigation/routing.
- Colors, spacing, and fonts live in `app_colors.dart` for easy theming — merge
  with your team's existing theme/colors file if you already have one.

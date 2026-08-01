// Barrel file — import this one file to get access to all
// notification-related screens and shared widgets, e.g.:
//
// ```dart
// import 'package:your_app/notification/notification.dart';
//
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => const ProfileScreen(),
// ));
// ```

export 'app_colors.dart';
export 'widgets/bottom_nav_bar.dart';
export 'screens/profile_screen.dart';
export 'screens/settings_screen.dart';
export 'screens/notifications_screen.dart';

// Models
export 'models/app_notification.dart';
export 'models/app_settings.dart';
export 'models/user_profile.dart';

// Services (Firebase + SharedPreferences backend)
export 'services/notification_service.dart';
export 'services/settings_service.dart';
export 'services/profile_service.dart';
export 'services/preferences_service.dart';
export 'services/fcm_service.dart';

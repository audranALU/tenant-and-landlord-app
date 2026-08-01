# Firebase Setup — tenant-and-landlord-app-fad4c

Project ID: `tenant-and-landlord-app-fad4c`. Since nothing's wired up yet,
here's the exact path from zero to running, using **Cloud Firestore**
(recommended over Realtime Database for this app — it supports the
`where(userId) + orderBy(createdAt)` queries the notification feed needs,
scales better with the grouped/paginated UI, and has offline persistence
built in).

## 1. One-time CLI setup

```bash
npm install -g firebase-tools
firebase login

dart pub global activate flutterfire_cli
```

## 2. Enable products in the Firebase Console

Go to https://console.firebase.google.com/project/tenant-and-landlord-app-fad4c
and enable:
- **Firestore Database** (start in production mode — the rules in
  `firebase/firestore.rules` handle security)
- **Authentication** — enable whatever sign-in method your app uses
  (Email/Password, Google, etc.) — all the code here assumes
  `FirebaseAuth.instance.currentUser` is already set by your team's
  existing auth flow.
- **Cloud Messaging** — no toggle needed, it's on by default, but note
  the **Sender ID / Server key** aren't used directly; FlutterFire config
  handles this.

## 3. Generate `firebase_options.dart`

From your Flutter project root (the one with `pubspec.yaml`, not this
`notification` folder):

```bash
flutterfire configure --project=tenant-and-landlord-app-fad4c
```

Select the platforms you're targeting (Android/iOS/Web). This writes
`lib/firebase_options.dart` and drops the native config files
(`google-services.json`, `GoogleService-Info.plist`) into place
automatically — nothing to copy by hand.

## 4. Initialize Firebase in your app's `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'notification/lib/services/fcm_service.dart'; // adjust path to wherever you placed the folder

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Call after the user is signed in (e.g. right after login succeeds):
  await FcmService.instance.initialize(
    onMessageTapped: (message) {
      // e.g. navigate to NotificationsScreen or a specific ticket
    },
  );

  runApp(const MyApp());
}
```

Also call `ProfileService.instance.ensureProfileExists(name: ...)` once,
right after a user signs up/signs in for the first time, so their
`users/{uid}` doc exists before ProfileScreen/SettingsScreen try to read it.

## 5. Deploy rules, indexes, and functions

From inside the `firebase/` folder (move/merge it into your team's repo
root first if you've already got a `firebase.json` there):

```bash
cd firebase
firebase deploy --only firestore:rules,firestore:indexes --project tenant-and-landlord-app-fad4c

cd functions
npm install
cd ..
firebase deploy --only functions --project tenant-and-landlord-app-fad4c
```

## 6. Add dependencies

Merge these into your team's `pubspec.yaml` if it's a separate file from
the one in this folder:

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
firebase_messaging: ^15.1.3
shared_preferences: ^2.3.2
flutter_local_notifications: ^18.0.1
```

Then `flutter pub get`.

## What's already handled for you

| Piece | Where |
|---|---|
| Notification records + real-time listeners | `lib/services/notification_service.dart` |
| SharedPreferences persistence/restore (settings + notification cache) | `lib/services/preferences_service.dart` |
| Settings sync (local-first, Firestore backup) | `lib/services/settings_service.dart` |
| Profile stats | `lib/services/profile_service.dart` |
| FCM token registration + foreground display | `lib/services/fcm_service.dart` |
| Security rules | `firebase/firestore.rules` |
| Push-sending Cloud Function + example triggers | `firebase/functions/index.js` |

## Firestore schema this all assumes

```
users/{uid}
  name: string
  photoUrl: string | null
  isPremium: bool
  propertiesCount: number
  activeTasksCount: number
  fcmTokens: string[]
  settings: { pushNotifications, emailAlerts, darkMode, lowDataMode }

notifications/{id}
  userId: string
  type: "message" | "status_update" | "service_scheduled" | "payment_confirmed" | "system_alert"
  title: string
  body: string
  ticketId: string | null
  metadata: map (e.g. { status: "IN PROGRESS" } for status_update)
  read: bool
  createdAt: Timestamp
```

`tickets` and `payments` collections referenced by the example Cloud
Functions triggers aren't defined here since they belong to the rest of
the app your group is building — adjust the field names in
`firebase/functions/index.js` (`onNewTicketMessage`, `onTicketStatusChanged`,
`onPaymentConfirmed`) to match whatever your team's actual schema turns
out to be.

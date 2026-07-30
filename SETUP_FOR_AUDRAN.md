# Tenant Feature — Setup Guide (for Audran)

These files fill in the tenant screens and provider that were empty. They plug
directly into the `MaintenanceRequestModel` and `MaintenanceService` you already
built — no changes needed to those.

## IMPORTANT: depends on the shared theme

These screens use the shared theme files (`lib/core/theme/app_colors.dart`,
`app_text_styles.dart`) and `lib/core/widgets/status_badge.dart`. Those live on
Emmanuella's branch (`feature/emmanuella-landlord-dashboard`). So **branch off her
branch**, not off main:

```bash
git fetch --all
git checkout feature/emmanuella-landlord-dashboard
git pull origin feature/emmanuella-landlord-dashboard
git checkout feature/audran-tenant-requests
git merge feature/emmanuella-landlord-dashboard
```

Resolve any conflicts (likely only in main.dart — keep both providers registered).

## Files & where they go (these REPLACE your empty 0-byte files)

| File | Path in project |
|---|---|
| `maintenance_provider.dart` | `lib/providers/maintenance_provider.dart` |
| `tenant_dashboard.dart` | `lib/tenant/tenant_dashboard.dart` |
| `create_request_screen.dart` | `lib/tenant/create_request_screen.dart` |
| `request_detail_screen.dart` | `lib/tenant/request_detail_screen.dart` |
| `edit_request_screen.dart` | `lib/tenant/edit_request_screen.dart` |

## Register the provider in main.dart

Add to the MultiProvider list (next to AuthProvider and LandlordProvider):

```dart
import 'providers/maintenance_provider.dart';
// ...
ChangeNotifierProvider(
  create: (_) => MaintenanceProvider(),
),
```

## After copying

```bash
flutter pub get
flutter analyze
```

Should be clean except the notification/ folder errors (those are Aurele's).

## To view your dashboard while testing

Role routing isn't built yet (Alain's task), so temporarily point auth_wrapper.dart
at the tenant dashboard:

```dart
import '../../tenant/tenant_dashboard.dart';
// ...
return const TenantDashboard(); // TEMP: revert to HomeScreen() after testing
```

## ONE THING LEFT FOR YOU: image upload

The create-request screen lets the user pick a photo (image_picker works), but
uploading it to Firebase Storage is stubbed — it currently saves an empty
imageUrl. To finish your feature per the task plan ("Firebase Storage image
upload"), wire up the upload in `create_request_screen.dart` `_submit()`:

```dart
String imageUrl = "";
if (_pickedImage != null) {
  final ref = FirebaseStorage.instance
      .ref()
      .child("request_images/${DateTime.now().millisecondsSinceEpoch}.jpg");
  await ref.putFile(_pickedImage!);
  imageUrl = await ref.getDownloadURL();
}
// then pass imageUrl into provider.createRequest(...)
```

You'll also add a unit test (`test/maintenance_provider_test.dart`) — mirror the
structure of Emmanuella's `test/landlord_provider_test.dart`.

## Data contract (must match — do not rename fields)

The `maintenance_requests` collection uses these exact fields. Emmanuella's
landlord dashboard and Ella's technician screens read the same ones:

tenantId, category, urgency, location, description, imageUrl, status, createdAt
(+ technicianId, technicianName, assignedAt — added by the landlord assignment flow)

Status values (lowercase): open, assigned, in_progress, resolved
Urgency values (lowercase): low, medium, high

# KG - passNew

Flutter/FlutterFlow mobile app for passenger trip booking and admin trip management.

## Product Scope

- Mobile and tablet are the primary targets.
- Desktop/web are not polished beyond avoiding critical breakage.
- No in-app payments in the current product scope.
- Roles: `passenger` and `admin`.
- Passenger flow: welcome, auth, trips list, trip details, seat selection, pending booking, my applications, cancel request by phone.
- Admin flow: create trips, view bookings, confirm pending bookings, save admin comments, remove bookings, delete trips.
- Backend: Supabase auth, Postgres tables/views/RLS, storage, notification queue, Edge Functions.

## Current Status

- MVP/pre-release readiness: Android emulator release-candidate.
- Implemented and checked: auth, role guards, first-launch welcome, passenger/admin flows, booking statuses, Supabase migrations, notification event queue, Pushy delivery path, typed tables, UX pass, tests, signed release APK, and final emulator QA.
- Remaining before external release: optional physical Android smoke and final product review of package name, app label, icon, splash, and version.

The single source of truth for project status is `PROJECT_FINISH_PLAN.md`.

## Requirements

- Flutter stable compatible with the checked-in project.
- Android Studio/JDK for Android builds.
- Android emulator or physical Android device for runtime/e2e checks.
- Supabase project access for backend verification and Edge Functions.

## Setup

```powershell
flutter pub get
```

The app currently uses the Supabase URL and anon key from `lib/backend/supabase/supabase.dart`. Do not commit service-role keys, keystores, passwords, or local signing secrets.

## Run

```powershell
flutter run
```

For a specific Android device:

```powershell
flutter devices
flutter run -d <device-id>
```

## Checks

Run these before handing off changes:

```powershell
flutter analyze
flutter test
flutter test integration_test/app_smoke_test.dart
flutter build apk --debug
```

Last confirmed locally on 2026-05-04:

- `flutter analyze` passed.
- `flutter test` passed.
- `flutter test integration_test/app_smoke_test.dart` passed.
- `flutter build apk --debug` passed.
- Local release signing was configured with `android/key.properties` and a keystore outside the repo.
- `flutter build apk --release` passed and produced `build/app/outputs/flutter-apk/app-release.apk`.
- `android/gradlew.bat bundleRelease` passed and produced `build/app/outputs/bundle/release/app-release.aab`; `jarsigner` verified the AAB signature.
- `apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-release.apk` passed.
- The signed release APK was installed on `emulator-5554`; Welcome, auth, admin route, passenger route, empty states, profile placeholder, and logcat smoke were checked.
- Temporary Supabase QA users/data were created for the smoke and cleaned up afterward.
- Real Supabase password recovery redirect to `kgpassnew://kgpassnew.com/updatePassword` was previously verified on Android: password reset succeeded, login with the new password worked, and the old password was rejected.

## Supabase

Important project files:

- `supabase/migrations/20260423_block3_data_backend.sql`
- `supabase/migrations/20260423_block4_cancel_notification_queue.sql`
- `supabase/migrations/20260424_block6_notifications_periodic.sql`
- `supabase/migrations/20260424_block6_user_devices_rls.sql`
- `supabase/migrations/20260502_pushy_device_registration.sql`
- `supabase/functions/dispatch-notification-events/index.ts`
- `supabase/functions/enqueue-trip-reminders/index.ts`
- `supabase/functions/admin-push-webhook/index.ts`

Before manual e2e smoke, Supabase should have:

- A passenger test account.
- An admin test account with `users.role = admin`.
- Basic `cities` and `cars` data.
- Storage bucket for avatars/images as expected by the app.

Do not store real test passwords in the repository.

## Android Release Notes

Current Android identifiers still need final product review:

- `applicationId`: `com.mycompany.kgpassnew`
- App label: `KG - passNew`
- Release builds require `android/key.properties`; debug signing fallback is disabled.
- This machine currently has local release signing configured with a keystore under the user profile, outside the repository.
- Release builds enable resource shrinking/minification.

Create `android/key.properties` locally only; do not commit it:

```properties
storeFile=C:/absolute/path/to/release-keystore.jks
storePassword=your-store-password
keyAlias=your-key-alias
keyPassword=your-key-password
```

Current local release artifacts:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

Before production or external testing, confirm the final package name, app name, icon, splash, version, and signing setup. `flutter doctor` currently reports missing Android cmdline-tools/license status in this environment; APK release builds and direct Gradle AAB builds still passed.

## Notification Delivery

This project does not use Firebase/FCM. Production push delivery is wired for Pushy:

- Flutter app registers a Pushy device token after login.
- `register_user_device(...)` stores the token in Supabase `user_devices`.
- `notification_events` are consumed by `dispatch-notification-events`.
- With `PUSH_PROVIDER=pushy`, the dispatcher sends each event to Pushy's Send Notifications API.
- With `PUSH_PROVIDER=webhook`, the dispatcher keeps the old internal test webhook flow.

Last checked on 2026-04-29 with service-role REST/Edge Function access:

- `user_devices` exists and returned Android test-device rows.
- `notification_events` queue exists and returned pending rows.
- `dispatch-notification-events?dry_run=true` returned `pending: 28`, `would_process: 7`, `skipped_no_recipients: 21`.
- `dispatch-notification-events` returned `processed: 7` and updated those rows with `processed_at`.
- Remaining pending passenger events have no matching rows in `user_devices` for their `recipient_user_id`.

Added on 2026-05-02:

- `pushy_flutter` SDK integration in the app.
- Android Pushy permissions, receivers, services, and ProGuard rules.
- Android 13+ runtime notification permission request in `MainActivity`, required for visible system notifications with `targetSdkVersion 36`.
- Supabase RPC migration `register_user_device(...)` for safe device-token upsert and stale token cleanup.
- Pushy provider mode in `dispatch-notification-events` using data-only Pushy payloads handled by the app listener.
- Remote Supabase setup completed with `PUSH_PROVIDER=pushy` / `PUSHY_SECRET_API_KEY`, deployed `dispatch-notification-events`, and verified `register_user_device` exists.
- Fresh login on `emulator-5554` registered a real Pushy token in `user_devices`.
- Live Pushy event `cf3bd041-58c2-497e-9c8c-2a5ce7d2977a` was delivered to Android; logcat showed the payload, Android notification shade showed the app notification, and `processed_at` was set.

Live push verification is complete on `emulator-5554`; repeat on a physical Android device before external release if required.

## Remaining Plan

1. Repeat the final smoke on a physical Android device before external release if required.
2. Confirm final package name, app label, icon, splash, version, and signing-key ownership before store submission.
3. Install Android cmdline-tools / accept licenses if the next handoff must use the Flutter wrapper command for AAB generation instead of direct Gradle.

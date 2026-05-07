# enqueue-trip-reminders

Edge Function wrapper around SQL function `public.enqueue_trip_reminder_events`.

## Purpose
- Backend-driven periodic action: enqueue `trip_reminder_1h` events.
- Works with a scheduler (cron) even when client app is closed.

## Required env vars
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

## Optional env vars
- `DISPATCHER_CRON_TOKEN` (if set, function requires `Authorization: Bearer <token>`)

## Invocation
- POST `.../functions/v1/enqueue-trip-reminders`
- Dry run: `.../functions/v1/enqueue-trip-reminders?dry_run=true`
- Custom window: `.../enqueue-trip-reminders?window_from_minutes=55&window_to_minutes=65`

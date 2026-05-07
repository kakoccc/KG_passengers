# dispatch-notification-events

Edge Function consumer for `public.notification_events` queue.

## Purpose
- Reads pending notification events (`processed_at is null`).
- Resolves recipients from `recipient_role` and `recipient_user_id` using `public.user_devices`.
- Sends data-only events through Pushy when `PUSH_PROVIDER=pushy`, or to the internal/test dispatcher webhook when `PUSH_PROVIDER=webhook`.
- Marks dispatched events as processed (`processed_at`).

This repository intentionally does not use Firebase/FCM. Production device push is wired through Pushy; webhook mode remains available for local/test dispatcher checks.

In Pushy mode, the Edge Function sends the title/body inside `data`. The Flutter client notification listener displays the system notification with `Pushy.notify(...)`, which keeps foreground/background behavior consistent and avoids duplicate provider-rendered notifications.

## Required env vars
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `PUSH_PROVIDER` (`pushy` for production delivery, `webhook` for test delivery)
- `PUSHY_SECRET_API_KEY` (required only when `PUSH_PROVIDER=pushy` and the request is not `dry_run`)
- `ADMIN_PUSH_WEBHOOK_URL` (required only when `PUSH_PROVIDER=webhook` and the request is not `dry_run`)

## Scheduled dispatch
- Migration `20260507000000_schedule_notification_dispatcher.sql` schedules `dispatch-notification-events` once per minute through `pg_cron` and `pg_net`.
- Store these Supabase Vault secrets before relying on the schedule:
- `project_url`: `https://<project-ref>.supabase.co`
- `service_role_key`: Supabase service role key, used as the Edge Function bearer token
- Keep `PUSH_PROVIDER=pushy` and `PUSHY_SECRET_API_KEY` configured on the Edge Function for production delivery.

For this repository you can use the built-in endpoint:
- `https://<project-ref>.supabase.co/functions/v1/admin-push-webhook`

## Optional env vars
- `ADMIN_PUSH_WEBHOOK_SECRET` (sent as `Authorization: Bearer ...`)
- `DISPATCHER_CRON_TOKEN` (protects function endpoint)
- `NOTIFICATION_EVENTS_BATCH_SIZE` (default: `50`)
- `PUSHY_API_URL` (default: `https://api.pushy.me/push`)

## Invocation
- POST `.../functions/v1/dispatch-notification-events`
- Dry run: `.../functions/v1/dispatch-notification-events?dry_run=true`

If `DISPATCHER_CRON_TOKEN` is set, send:
- `Authorization: Bearer <DISPATCHER_CRON_TOKEN>`

# admin-push-webhook

Internal webhook endpoint for `dispatch-notification-events`.

## Purpose
- Accepts batched notification payload from dispatcher.
- Returns `200 OK` so dispatcher can mark events as processed.
- Emits compact logs for operational visibility.

## Auth
- If `ADMIN_PUSH_WEBHOOK_SECRET` is set, requires:
  - `Authorization: Bearer <ADMIN_PUSH_WEBHOOK_SECRET>`

## Invocation
- POST `.../functions/v1/admin-push-webhook`

begin;

create extension if not exists pgcrypto;

create table if not exists public.notification_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  recipient_role text not null default 'admin',
  booking_id uuid not null references public.bookings(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete cascade,
  actor_user_id uuid references public.users(id) on delete set null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  processed_at timestamptz
);

alter table public.notification_events
  drop constraint if exists notification_events_event_type_check;

alter table public.notification_events
  add constraint notification_events_event_type_check
  check (event_type in ('booking_cancel_requested'));

alter table public.notification_events
  drop constraint if exists notification_events_recipient_role_check;

alter table public.notification_events
  add constraint notification_events_recipient_role_check
  check (recipient_role in ('admin'));

create unique index if not exists notification_events_unique_event_booking_recipient
  on public.notification_events (event_type, booking_id, recipient_role);

create index if not exists notification_events_created_at_idx
  on public.notification_events (created_at desc);

create index if not exists notification_events_recipient_role_created_at_idx
  on public.notification_events (recipient_role, created_at desc);

alter table public.notification_events enable row level security;

drop policy if exists notification_events_insert_cancel_request on public.notification_events;
create policy notification_events_insert_cancel_request
  on public.notification_events
  for insert
  to authenticated
  with check (
    event_type = 'booking_cancel_requested'
    and recipient_role = 'admin'
    and actor_user_id = auth.uid()
  );

drop policy if exists notification_events_select_actor on public.notification_events;
create policy notification_events_select_actor
  on public.notification_events
  for select
  to authenticated
  using (actor_user_id = auth.uid());

drop policy if exists notification_events_select_admin on public.notification_events;
create policy notification_events_select_admin
  on public.notification_events
  for select
  to authenticated
  using (
    recipient_role = 'admin'
    and exists (
      select 1
      from public.users u
      where u.id = auth.uid()
        and u.role = 'admin'
    )
  );

commit;

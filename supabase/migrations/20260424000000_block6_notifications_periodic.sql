begin;

-- 1) Extend notification_events for full Block 6 event model
alter table public.notification_events
  add column if not exists recipient_user_id uuid;

alter table public.notification_events
  alter column booking_id drop not null;

do $$
declare
  fk_name text;
begin
  -- booking_id FK
  for fk_name in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'notification_events'
      and c.contype = 'f'
      and pg_get_constraintdef(c.oid) ilike 'FOREIGN KEY (booking_id)%'
  loop
    execute format('alter table public.notification_events drop constraint %I', fk_name);
  end loop;

  -- trip_id FK
  for fk_name in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'notification_events'
      and c.contype = 'f'
      and pg_get_constraintdef(c.oid) ilike 'FOREIGN KEY (trip_id)%'
  loop
    execute format('alter table public.notification_events drop constraint %I', fk_name);
  end loop;

  -- recipient_user_id FK (if any stale definition exists)
  for fk_name in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'notification_events'
      and c.contype = 'f'
      and pg_get_constraintdef(c.oid) ilike 'FOREIGN KEY (recipient_user_id)%'
  loop
    execute format('alter table public.notification_events drop constraint %I', fk_name);
  end loop;
end $$;

alter table public.notification_events
  add constraint notification_events_booking_id_fkey
  foreign key (booking_id)
  references public.bookings(id)
  on delete set null;

alter table public.notification_events
  add constraint notification_events_trip_id_fkey
  foreign key (trip_id)
  references public.trips(id)
  on delete set null;

alter table public.notification_events
  add constraint notification_events_recipient_user_id_fkey
  foreign key (recipient_user_id)
  references public.users(id)
  on delete set null;

alter table public.notification_events
  drop constraint if exists notification_events_event_type_check;

alter table public.notification_events
  add constraint notification_events_event_type_check
  check (
    event_type in (
      'booking_created',
      'booking_confirmed',
      'booking_removed',
      'booking_cancel_requested',
      'trip_deleted',
      'trip_reminder_1h'
    )
  );

alter table public.notification_events
  drop constraint if exists notification_events_recipient_role_check;

alter table public.notification_events
  add constraint notification_events_recipient_role_check
  check (recipient_role in ('admin', 'passenger'));

alter table public.notification_events
  drop constraint if exists notification_events_recipient_user_consistency_check;

alter table public.notification_events
  add constraint notification_events_recipient_user_consistency_check
  check (
    (recipient_role = 'admin' and recipient_user_id is null)
    or (recipient_role = 'passenger' and recipient_user_id is not null)
  );

drop index if exists public.notification_events_unique_event_booking_recipient;

create unique index if not exists notification_events_unique_admin_booking_event
  on public.notification_events (event_type, booking_id, recipient_role)
  where recipient_role = 'admin'
    and booking_id is not null;

create unique index if not exists notification_events_unique_passenger_booking_event
  on public.notification_events (event_type, booking_id, recipient_role, recipient_user_id)
  where recipient_role = 'passenger'
    and booking_id is not null
    and recipient_user_id is not null;

create unique index if not exists notification_events_unique_passenger_trip_event
  on public.notification_events (event_type, trip_id, recipient_role, recipient_user_id)
  where recipient_role = 'passenger'
    and trip_id is not null
    and recipient_user_id is not null;

create index if not exists notification_events_pending_idx
  on public.notification_events (created_at asc)
  where processed_at is null;

create index if not exists notification_events_recipient_user_id_idx
  on public.notification_events (recipient_user_id);

-- 2) Tighten RLS policies for queue writes/reads
drop policy if exists notification_events_insert_cancel_request on public.notification_events;
create policy notification_events_insert_cancel_request
  on public.notification_events
  for insert
  to authenticated
  with check (
    event_type = 'booking_cancel_requested'
    and recipient_role = 'admin'
    and recipient_user_id is null
    and actor_user_id = auth.uid()
    and exists (
      select 1
      from public.bookings b
      where b.id = booking_id
        and b.user_id = auth.uid()
    )
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

drop policy if exists notification_events_select_recipient_passenger on public.notification_events;
create policy notification_events_select_recipient_passenger
  on public.notification_events
  for select
  to authenticated
  using (
    recipient_role = 'passenger'
    and recipient_user_id = auth.uid()
  );

-- 3) Utility function for idempotent queue insertions from triggers/jobs
create or replace function public.enqueue_notification_event(
  p_event_type text,
  p_recipient_role text,
  p_booking_id uuid default null,
  p_trip_id uuid default null,
  p_recipient_user_id uuid default null,
  p_actor_user_id uuid default null,
  p_payload jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notification_events (
    event_type,
    recipient_role,
    booking_id,
    trip_id,
    recipient_user_id,
    actor_user_id,
    payload
  )
  values (
    p_event_type,
    p_recipient_role,
    p_booking_id,
    p_trip_id,
    p_recipient_user_id,
    p_actor_user_id,
    coalesce(p_payload, '{}'::jsonb)
  )
  on conflict do nothing;
end;
$$;

revoke all on function public.enqueue_notification_event(text, text, uuid, uuid, uuid, uuid, jsonb) from public;
grant execute on function public.enqueue_notification_event(text, text, uuid, uuid, uuid, uuid, jsonb) to service_role;

-- 4) DB triggers for backend-driven event production
create or replace function public.trg_bookings_notify_after_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.enqueue_notification_event(
    p_event_type => 'booking_created',
    p_recipient_role => 'admin',
    p_booking_id => new.id,
    p_trip_id => new.trip_id,
    p_actor_user_id => coalesce(auth.uid(), new.user_id),
    p_payload => jsonb_build_object(
      'status', new.status,
      'source', 'bookings_after_insert'
    )
  );

  if new.status = 'confirmed' and new.user_id is not null then
    perform public.enqueue_notification_event(
      p_event_type => 'booking_confirmed',
      p_recipient_role => 'passenger',
      p_booking_id => new.id,
      p_trip_id => new.trip_id,
      p_recipient_user_id => new.user_id,
      p_actor_user_id => auth.uid(),
      p_payload => jsonb_build_object(
        'status', new.status,
        'source', 'bookings_after_insert'
      )
    );
  end if;

  return new;
end;
$$;

create or replace function public.trg_bookings_notify_after_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.status is distinct from new.status then
    if new.status = 'cancel_requested' then
      perform public.enqueue_notification_event(
        p_event_type => 'booking_cancel_requested',
        p_recipient_role => 'admin',
        p_booking_id => new.id,
        p_trip_id => new.trip_id,
        p_actor_user_id => coalesce(auth.uid(), new.user_id),
        p_payload => jsonb_build_object(
          'status', new.status,
          'source', 'bookings_after_update'
        )
      );
    end if;

    if new.status = 'confirmed' and new.user_id is not null then
      perform public.enqueue_notification_event(
        p_event_type => 'booking_confirmed',
        p_recipient_role => 'passenger',
        p_booking_id => new.id,
        p_trip_id => new.trip_id,
        p_recipient_user_id => new.user_id,
        p_actor_user_id => auth.uid(),
        p_payload => jsonb_build_object(
          'status', new.status,
          'source', 'bookings_after_update'
        )
      );
    end if;
  end if;

  return new;
end;
$$;

create or replace function public.trg_trips_notify_before_delete()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notification_events (
    event_type,
    recipient_role,
    booking_id,
    trip_id,
    recipient_user_id,
    actor_user_id,
    payload
  )
  select
    'trip_deleted',
    'passenger',
    b.id,
    b.trip_id,
    b.user_id,
    auth.uid(),
    jsonb_build_object(
      'source', 'trips_before_delete',
      'booking_status', b.status
    )
  from public.bookings b
  where b.trip_id = old.id
    and b.user_id is not null
  on conflict do nothing;

  return old;
end;
$$;

create or replace function public.trg_bookings_notify_before_delete()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.user_id is not null
     and not exists (
       select 1
       from public.notification_events ne
       where ne.event_type = 'trip_deleted'
         and ne.booking_id = old.id
         and ne.recipient_user_id = old.user_id
     )
  then
    perform public.enqueue_notification_event(
      p_event_type => 'booking_removed',
      p_recipient_role => 'passenger',
      p_booking_id => old.id,
      p_trip_id => old.trip_id,
      p_recipient_user_id => old.user_id,
      p_actor_user_id => auth.uid(),
      p_payload => jsonb_build_object(
        'source', 'bookings_before_delete',
        'status_before_delete', old.status
      )
    );
  end if;

  return old;
end;
$$;

drop trigger if exists bookings_notify_after_insert on public.bookings;
create trigger bookings_notify_after_insert
after insert on public.bookings
for each row
execute function public.trg_bookings_notify_after_insert();

drop trigger if exists bookings_notify_after_update on public.bookings;
create trigger bookings_notify_after_update
after update of status on public.bookings
for each row
execute function public.trg_bookings_notify_after_update();

drop trigger if exists bookings_notify_before_delete on public.bookings;
create trigger bookings_notify_before_delete
before delete on public.bookings
for each row
execute function public.trg_bookings_notify_before_delete();

drop trigger if exists trips_notify_before_delete on public.trips;
create trigger trips_notify_before_delete
before delete on public.trips
for each row
execute function public.trg_trips_notify_before_delete();

-- 5) Periodic reminder enqueue function (backend scheduled job)
create or replace function public.enqueue_trip_reminder_events(
  window_from_minutes int default 55,
  window_to_minutes int default 65,
  preview_only boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_candidates int := 0;
  v_inserted int := 0;
begin
  with candidates as (
    select
      b.id as booking_id,
      b.user_id,
      b.trip_id,
      case
        when t.departure_date is null then null
        when t.departure_time_only is not null
          then (date_trunc('day', t.departure_date) + t.departure_time_only)::timestamptz
        else t.departure_date::timestamptz
      end as departure_at
    from public.bookings b
    join public.trips t on t.id = b.trip_id
    where b.status = 'confirmed'
      and b.user_id is not null
  )
  select count(*)::int into v_candidates
  from candidates c
  where c.departure_at is not null
    and c.departure_at >= now() + make_interval(mins => window_from_minutes)
    and c.departure_at <= now() + make_interval(mins => window_to_minutes);

  if preview_only then
    return jsonb_build_object(
      'preview_only', true,
      'window_from_minutes', window_from_minutes,
      'window_to_minutes', window_to_minutes,
      'candidates', v_candidates,
      'inserted', 0
    );
  end if;

  with candidates as (
    select
      b.id as booking_id,
      b.user_id,
      b.trip_id,
      case
        when t.departure_date is null then null
        when t.departure_time_only is not null
          then (date_trunc('day', t.departure_date) + t.departure_time_only)::timestamptz
        else t.departure_date::timestamptz
      end as departure_at
    from public.bookings b
    join public.trips t on t.id = b.trip_id
    where b.status = 'confirmed'
      and b.user_id is not null
  )
  insert into public.notification_events (
    event_type,
    recipient_role,
    booking_id,
    trip_id,
    recipient_user_id,
    actor_user_id,
    payload
  )
  select
    'trip_reminder_1h',
    'passenger',
    c.booking_id,
    c.trip_id,
    c.user_id,
    null,
    jsonb_build_object(
      'source', 'enqueue_trip_reminder_events',
      'departure_at', c.departure_at
    )
  from candidates c
  where c.departure_at is not null
    and c.departure_at >= now() + make_interval(mins => window_from_minutes)
    and c.departure_at <= now() + make_interval(mins => window_to_minutes)
  on conflict do nothing;

  get diagnostics v_inserted = row_count;

  return jsonb_build_object(
    'preview_only', false,
    'window_from_minutes', window_from_minutes,
    'window_to_minutes', window_to_minutes,
    'candidates', v_candidates,
    'inserted', v_inserted
  );
end;
$$;

revoke all on function public.enqueue_trip_reminder_events(int, int, boolean) from public;
grant execute on function public.enqueue_trip_reminder_events(int, int, boolean) to service_role;

commit;

begin;

-- 1) bookings.status: canonical states + default
update public.bookings
set status = 'pending'
where status is null
   or status not in ('pending', 'confirmed', 'cancel_requested');

alter table public.bookings
  alter column status set default 'pending';

alter table public.bookings
  drop constraint if exists bookings_status_check;

alter table public.bookings
  add constraint bookings_status_check
  check (status in ('pending', 'confirmed', 'cancel_requested'));

-- 2) bookings.admin_comment for internal manager notes
alter table public.bookings
  add column if not exists admin_comment text;

-- 3) Server-side protection from duplicate booking by one user for same trip
with ranked as (
  select
    id,
    row_number() over (
      partition by trip_id, user_id
      order by created_at nulls last, id
    ) as rn
  from public.bookings
  where trip_id is not null
    and user_id is not null
    and status in ('pending', 'confirmed', 'cancel_requested')
)
delete from public.bookings b
using ranked r
where b.id = r.id
  and r.rn > 1;

create unique index if not exists bookings_trip_user_unique
  on public.bookings (trip_id, user_id)
  where trip_id is not null
    and user_id is not null
    and status in ('pending', 'confirmed', 'cancel_requested');

-- 4) Ensure trip deletion cleans related bookings (ON DELETE CASCADE)
do $$
declare
  fk_name text;
begin
  for fk_name in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'bookings'
      and c.contype = 'f'
      and pg_get_constraintdef(c.oid) ilike 'FOREIGN KEY (trip_id)%'
  loop
    execute format('alter table public.bookings drop constraint %I', fk_name);
  end loop;

  execute '
    alter table public.bookings
      add constraint bookings_trip_id_fkey
      foreign key (trip_id)
      references public.trips(id)
      on delete cascade
  ';
end $$;

-- 5) trips_view.available_seats
-- Wrap current view definition to avoid duplicating full source SQL here.
do $$
declare
  view_sql text;
begin
  if exists (
    select 1
    from information_schema.views
    where table_schema = 'public'
      and table_name = 'trips_view'
  ) and not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'trips_view'
      and column_name = 'available_seats'
  ) then
    select pg_get_viewdef('public.trips_view'::regclass, true) into view_sql;

    -- pg_get_viewdef can include trailing ';', strip it before nesting in FROM (%s)
    view_sql := trim(both from view_sql);
    view_sql := regexp_replace(view_sql, E';\\s*$', '');

    execute format($sql$
      create or replace view public.trips_view as
      select
        v.*,
        greatest(coalesce(v.total_seats, 0) - coalesce(b.active_bookings, 0), 0)::int as available_seats
      from (%s) as v
      left join lateral (
        select count(*)::int as active_bookings
        from public.bookings b
        where b.trip_id = v.id
          and b.status in ('pending', 'confirmed', 'cancel_requested')
      ) b on true
    $sql$, view_sql);
  end if;
end $$;

-- 6) Storage for push tokens
create extension if not exists pgcrypto;

create table if not exists public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  device_token text not null,
  platform text,
  app_version text,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, device_token)
);

create index if not exists user_devices_user_id_idx
  on public.user_devices (user_id);

-- 7) trips.created_by should reference an existing admin/user id
do $$
begin
  if not exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'trips'
      and c.conname = 'trips_created_by_fkey'
  ) then
    alter table public.trips
      add constraint trips_created_by_fkey
      foreign key (created_by)
      references public.users(id)
      on update cascade
      on delete set null;
  end if;
exception
  when undefined_column or undefined_table then
    null;
end $$;

commit;

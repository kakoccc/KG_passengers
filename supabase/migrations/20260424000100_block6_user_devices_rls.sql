begin;

alter table public.user_devices enable row level security;

-- Do not expose device tokens publicly.
revoke all on table public.user_devices from anon;
grant select, insert, update, delete on table public.user_devices to authenticated;

drop policy if exists user_devices_select_own on public.user_devices;
create policy user_devices_select_own
  on public.user_devices
  for select
  to authenticated
  using (user_id = auth.uid());

drop policy if exists user_devices_insert_own on public.user_devices;
create policy user_devices_insert_own
  on public.user_devices
  for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists user_devices_update_own on public.user_devices;
create policy user_devices_update_own
  on public.user_devices
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists user_devices_delete_own on public.user_devices;
create policy user_devices_delete_own
  on public.user_devices
  for delete
  to authenticated
  using (user_id = auth.uid());

commit;

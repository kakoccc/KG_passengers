begin;

create or replace function public.register_user_device(
  p_device_token text,
  p_platform text default null,
  p_app_version text default null
)
returns public.user_devices
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_device public.user_devices;
begin
  if v_user_id is null then
    raise exception 'register_user_device requires an authenticated user';
  end if;

  if p_device_token is null or length(trim(p_device_token)) = 0 then
    raise exception 'p_device_token is required';
  end if;

  delete from public.user_devices
  where device_token = trim(p_device_token)
    and user_id <> v_user_id;

  insert into public.user_devices (
    user_id,
    device_token,
    platform,
    app_version,
    last_seen_at,
    updated_at
  )
  values (
    v_user_id,
    trim(p_device_token),
    nullif(trim(coalesce(p_platform, '')), ''),
    nullif(trim(coalesce(p_app_version, '')), ''),
    now(),
    now()
  )
  on conflict (user_id, device_token)
  do update set
    platform = excluded.platform,
    app_version = excluded.app_version,
    last_seen_at = now(),
    updated_at = now()
  returning * into v_device;

  return v_device;
end;
$$;

revoke all on function public.register_user_device(text, text, text) from public;
grant execute on function public.register_user_device(text, text, text) to authenticated;

commit;

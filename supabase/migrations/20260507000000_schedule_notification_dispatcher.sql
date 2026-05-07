begin;

create extension if not exists pg_net with schema extensions;
create extension if not exists pg_cron with schema extensions;

create or replace function public.dispatch_pending_notification_events()
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_url text;
  v_service_role_key text;
begin
  select decrypted_secret into v_project_url
  from vault.decrypted_secrets
  where name = 'project_url';

  select decrypted_secret into v_service_role_key
  from vault.decrypted_secrets
  where name = 'service_role_key';

  if v_project_url is null or length(trim(v_project_url)) = 0 then
    raise exception 'vault secret project_url is required';
  end if;

  if v_service_role_key is null or length(trim(v_service_role_key)) = 0 then
    raise exception 'vault secret service_role_key is required';
  end if;

  perform net.http_post(
    url := trim(trailing '/' from v_project_url) || '/functions/v1/dispatch-notification-events',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_service_role_key
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 15000
  );
end;
$$;

revoke all on function public.dispatch_pending_notification_events() from public;
grant execute on function public.dispatch_pending_notification_events() to service_role;

select cron.unschedule('dispatch-notification-events')
where exists (
  select 1
  from cron.job
  where jobname = 'dispatch-notification-events'
);

select cron.schedule(
  'dispatch-notification-events',
  '* * * * *',
  'select public.dispatch_pending_notification_events();'
);

commit;

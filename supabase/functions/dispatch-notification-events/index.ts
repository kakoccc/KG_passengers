import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.8';
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

type NotificationEvent = {
  id: string;
  event_type: string;
  recipient_role: string;
  booking_id: string | null;
  trip_id: string | null;
  recipient_user_id: string | null;
  actor_user_id: string | null;
  payload: Record<string, unknown> | null;
  created_at: string;
  processed_at: string | null;
};

type Device = {
  user_id: string;
  device_token: string;
  platform: string | null;
  app_version: string | null;
};

const supabaseUrl = Deno.env.get('SUPABASE_URL');
const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const dispatcherWebhookUrl = Deno.env.get('ADMIN_PUSH_WEBHOOK_URL');
const dispatcherWebhookSecret = Deno.env.get('ADMIN_PUSH_WEBHOOK_SECRET') ?? '';
const dispatcherAuthToken = Deno.env.get('DISPATCHER_CRON_TOKEN') ?? '';
const batchSize = Number(Deno.env.get('NOTIFICATION_EVENTS_BATCH_SIZE') ?? '50');
const pushySecretApiKey = Deno.env.get('PUSHY_SECRET_API_KEY') ?? '';
const pushyApiUrl = Deno.env.get('PUSHY_API_URL') ?? 'https://api.pushy.me/push';
const pushProvider = (
  Deno.env.get('PUSH_PROVIDER') ?? (pushySecretApiKey ? 'pushy' : 'webhook')
).toLowerCase();

if (!supabaseUrl || !supabaseServiceRoleKey) {
  throw new Error(
    'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be configured.',
  );
}

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

function unauthorized(message: string): Response {
  return new Response(JSON.stringify({ ok: false, error: message }), {
    status: 401,
    headers: { 'Content-Type': 'application/json' },
  });
}

function isAuthorizedDispatcherRequest(req: Request): boolean {
  const authHeader = req.headers.get('Authorization') ?? '';
  const acceptedTokens = [dispatcherAuthToken, supabaseServiceRoleKey].filter(
    (token): token is string => Boolean(token),
  );

  if (acceptedTokens.length === 0) {
    return true;
  }

  return acceptedTokens.some((token) => authHeader === `Bearer ${token}`);
}

async function fetchPendingEvents(limit: number): Promise<NotificationEvent[]> {
  const { data, error } = await supabase
    .from('notification_events')
    .select(
      'id,event_type,recipient_role,booking_id,trip_id,recipient_user_id,actor_user_id,payload,created_at,processed_at',
    )
    .is('processed_at', null)
    .order('created_at', { ascending: true })
    .limit(limit);

  if (error) {
    throw new Error(`Failed to fetch notification_events: ${error.message}`);
  }
  return (data ?? []) as NotificationEvent[];
}

async function fetchAdminUserIds(): Promise<string[]> {
  const { data: admins, error: adminsError } = await supabase
    .from('users')
    .select('id')
    .eq('role', 'admin');
  if (adminsError) {
    throw new Error(`Failed to fetch admin users: ${adminsError.message}`);
  }
  return (admins ?? []).map((item) => item.id).filter(Boolean);
}

async function fetchDevicesForUsers(userIds: string[]): Promise<Device[]> {
  if (userIds.length === 0) {
    return [];
  }

  const { data: devices, error: devicesError } = await supabase
    .from('user_devices')
    .select('user_id,device_token,platform,app_version')
    .in('user_id', userIds);
  if (devicesError) {
    throw new Error(`Failed to fetch user_devices: ${devicesError.message}`);
  }

  return (devices ?? []) as Device[];
}

function mapDevicesByUser(devices: Device[]): Map<string, Device[]> {
  const map = new Map<string, Device[]>();
  for (const device of devices) {
    const existing = map.get(device.user_id) ?? [];
    existing.push(device);
    map.set(device.user_id, existing);
  }
  return map;
}

function uniqueStrings(values: string[]): string[] {
  return [...new Set(values.filter((value) => value && value.length > 0))];
}

async function markEventsAsProcessed(eventIds: string[]): Promise<void> {
  if (eventIds.length == 0) {
    return;
  }

  const { error } = await supabase
    .from('notification_events')
    .update({ processed_at: new Date().toISOString() })
    .in('id', eventIds);

  if (error) {
    throw new Error(`Failed to mark events as processed: ${error.message}`);
  }
}

function resolveDispatchPlan(
  pendingEvents: NotificationEvent[],
  adminUserIds: string[],
  devicesByUser: Map<string, Device[]>,
): {
  dispatchable: Array<{ event: NotificationEvent; recipients: Device[] }>;
  skippedNoRecipients: NotificationEvent[];
} {
  const dispatchable: Array<{ event: NotificationEvent; recipients: Device[] }> =
    [];
  const skippedNoRecipients: NotificationEvent[] = [];

  const adminDevices = adminUserIds.flatMap(
    (userId) => devicesByUser.get(userId) ?? [],
  );

  for (const event of pendingEvents) {
    let recipients: Device[] = [];

    if (event.recipient_role === 'admin') {
      recipients = adminDevices;
    } else if (
      event.recipient_role === 'passenger' &&
      event.recipient_user_id !== null
    ) {
      recipients = devicesByUser.get(event.recipient_user_id) ?? [];
    }

    if (recipients.length === 0) {
      skippedNoRecipients.push(event);
      continue;
    }

    dispatchable.push({ event, recipients });
  }

  return { dispatchable, skippedNoRecipients };
}

async function dispatchToWebhook(payload: Record<string, unknown>): Promise<void> {
  if (!dispatcherWebhookUrl) {
    throw new Error('ADMIN_PUSH_WEBHOOK_URL is not configured.');
  }

  const response = await fetch(dispatcherWebhookUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(dispatcherWebhookSecret
        ? { Authorization: `Bearer ${dispatcherWebhookSecret}` }
        : {}),
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(
      `Dispatcher webhook failed (${response.status}): ${body || 'empty body'}`,
    );
  }
}

function notificationCopy(event: NotificationEvent): {
  title: string;
  body: string;
} {
  switch (event.event_type) {
    case 'booking_created':
      return {
        title: 'Новая заявка',
        body: 'Поступила новая заявка на поездку.',
      };
    case 'booking_cancel_requested':
      return {
        title: 'Запрос на отмену',
        body: 'Пассажир запросил отмену брони.',
      };
    case 'booking_confirmed':
      return {
        title: 'Бронь подтверждена',
        body: 'Администратор подтвердил вашу бронь.',
      };
    case 'booking_removed':
      return {
        title: 'Бронь снята',
        body: 'Ваша бронь была снята администратором.',
      };
    case 'trip_deleted':
      return {
        title: 'Рейс удалён',
        body: 'Рейс, на который была заявка, удалён.',
      };
    case 'trip_reminder_1h':
      return {
        title: 'Скоро поездка',
        body: 'До поездки остался примерно 1 час.',
      };
    default:
      return {
        title: 'KG - passNew',
        body: 'У вас новое уведомление.',
      };
  }
}

function pushyEndpoint(): string {
  const url = new URL(pushyApiUrl);
  url.searchParams.set('api_key', pushySecretApiKey);
  return url.toString();
}

async function dispatchToPushy(
  event: NotificationEvent,
  recipients: Device[],
): Promise<Record<string, unknown>> {
  if (!pushySecretApiKey) {
    throw new Error('PUSHY_SECRET_API_KEY is not configured.');
  }

  const tokens = uniqueStrings(
    recipients.map((device) => device.device_token.trim()),
  );
  if (tokens.length === 0) {
    throw new Error(`No Pushy device tokens for event ${event.id}.`);
  }

  const copy = notificationCopy(event);
  const data = {
    ...(event.payload ?? {}),
    event_id: event.id,
    event_type: event.event_type,
    recipient_role: event.recipient_role,
    recipient_user_id: event.recipient_user_id,
    booking_id: event.booking_id,
    trip_id: event.trip_id,
    actor_user_id: event.actor_user_id,
    created_at: event.created_at,
    title: copy.title,
    message: copy.body,
  };

  const response = await fetch(pushyEndpoint(), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      to: tokens.length === 1 ? tokens[0] : tokens,
      data,
      time_to_live: 2592000,
    }),
  });

  const responseText = await response.text();
  let responseBody: Record<string, unknown> = {};
  if (responseText) {
    try {
      responseBody = JSON.parse(responseText) as Record<string, unknown>;
    } catch (_) {
      responseBody = { raw: responseText };
    }
  }

  if (!response.ok) {
    throw new Error(
      `Pushy send failed (${response.status}): ${responseText || 'empty body'}`,
    );
  }

  return responseBody;
}

async function dispatchEvents(
  dispatchable: Array<{ event: NotificationEvent; recipients: Device[] }>,
  webhookPayload: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  if (pushProvider === 'pushy') {
    const results: Record<string, unknown>[] = [];
    for (const item of dispatchable) {
      results.push(await dispatchToPushy(item.event, item.recipients));
    }
    return {
      provider: 'pushy',
      sent_events: results.length,
      results,
    };
  }

  if (pushProvider === 'webhook') {
    await dispatchToWebhook(webhookPayload);
    return {
      provider: 'webhook',
      sent_events: dispatchable.length,
    };
  }

  throw new Error(`Unsupported PUSH_PROVIDER: ${pushProvider}`);
}

serve(async (req) => {
  try {
    if (!isAuthorizedDispatcherRequest(req)) {
      return unauthorized('Invalid dispatcher token.');
    }

    const url = new URL(req.url);
    const dryRun = url.searchParams.get('dry_run') === 'true';

    const pendingEvents = await fetchPendingEvents(batchSize);
    if (pendingEvents.length == 0) {
      return new Response(
        JSON.stringify({
          ok: true,
          pending: 0,
          would_process: 0,
          processed: 0,
          skipped_no_recipients: 0,
          dry_run: dryRun,
          message: 'No pending notification events.',
        }),
        { headers: { 'Content-Type': 'application/json' } },
      );
    }

    const hasAdminEvents = pendingEvents.some(
      (event) => event.recipient_role === 'admin',
    );
    const adminUserIds = hasAdminEvents ? await fetchAdminUserIds() : [];

    const targetUserIds = uniqueStrings([
      ...adminUserIds,
      ...pendingEvents
        .filter((event) => event.recipient_role === 'passenger')
        .map((event) => event.recipient_user_id ?? ''),
    ]);
    const devices = await fetchDevicesForUsers(targetUserIds);
    const devicesByUser = mapDevicesByUser(devices);
    const { dispatchable, skippedNoRecipients } = resolveDispatchPlan(
      pendingEvents,
      adminUserIds,
      devicesByUser,
    );

    if (dispatchable.length === 0) {
      return new Response(
        JSON.stringify({
          ok: true,
          pending: pendingEvents.length,
          would_process: 0,
          processed: 0,
          skipped_no_recipients: skippedNoRecipients.length,
          dry_run: dryRun,
          message: 'No recipient devices found in user_devices.',
        }),
        { headers: { 'Content-Type': 'application/json' } },
      );
    }

    if (pushProvider === 'pushy' && !pushySecretApiKey && !dryRun) {
      return new Response(
        JSON.stringify({
          ok: false,
          provider: pushProvider,
          pending: pendingEvents.length,
          would_process: dispatchable.length,
          processed: 0,
          skipped_no_recipients: skippedNoRecipients.length,
          dry_run: dryRun,
          message: 'PUSHY_SECRET_API_KEY is not configured.',
        }),
        {
          status: 501,
          headers: { 'Content-Type': 'application/json' },
        },
      );
    }

    if (pushProvider === 'webhook' && !dispatcherWebhookUrl && !dryRun) {
      return new Response(
        JSON.stringify({
          ok: false,
          provider: pushProvider,
          pending: pendingEvents.length,
          would_process: dispatchable.length,
          processed: 0,
          skipped_no_recipients: skippedNoRecipients.length,
          dry_run: dryRun,
          message: 'ADMIN_PUSH_WEBHOOK_URL is not configured.',
        }),
        {
          status: 501,
          headers: { 'Content-Type': 'application/json' },
        },
      );
    }

    const dispatchableEventIds = uniqueStrings(
      dispatchable.map((item) => item.event.id),
    );
    const dispatchPayload = {
      channel: 'notification_events',
      created_at: new Date().toISOString(),
      items: dispatchable.map((item) => ({
        id: item.event.id,
        event_type: item.event.event_type,
        recipient_role: item.event.recipient_role,
        recipient_user_id: item.event.recipient_user_id,
        booking_id: item.event.booking_id,
        trip_id: item.event.trip_id,
        actor_user_id: item.event.actor_user_id,
        payload: item.event.payload ?? {},
        created_at: item.event.created_at,
        recipients: item.recipients.map((device) => ({
          user_id: device.user_id,
          device_token: device.device_token,
          platform: device.platform,
          app_version: device.app_version,
        })),
      })),
    };

    let providerResult: Record<string, unknown> = {
      provider: pushProvider,
      dry_run: true,
    };
    if (!dryRun) {
      providerResult = await dispatchEvents(dispatchable, dispatchPayload);
      await markEventsAsProcessed(dispatchableEventIds);
    }

    return new Response(
      JSON.stringify({
        ok: true,
        pending: pendingEvents.length,
        provider: providerResult.provider,
        provider_result: providerResult,
        would_process: dispatchable.length,
        processed: dryRun ? 0 : dispatchableEventIds.length,
        skipped_no_recipients: skippedNoRecipients.length,
        dry_run: dryRun,
      }),
      { headers: { 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return new Response(JSON.stringify({ ok: false, error: message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});

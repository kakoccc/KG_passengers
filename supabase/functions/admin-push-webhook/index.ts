import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

type DispatchItem = {
  id?: string;
  event_type?: string;
  recipient_role?: string;
  recipient_user_id?: string | null;
  booking_id?: string | null;
  trip_id?: string | null;
  created_at?: string;
  recipients?: Array<{
    user_id?: string;
    device_token?: string;
    platform?: string | null;
    app_version?: string | null;
  }>;
};

type DispatchPayload = {
  channel?: string;
  created_at?: string;
  items?: DispatchItem[];
};

const webhookSecret = Deno.env.get('ADMIN_PUSH_WEBHOOK_SECRET') ?? '';

function unauthorized(message: string): Response {
  return new Response(JSON.stringify({ ok: false, error: message }), {
    status: 401,
    headers: { 'Content-Type': 'application/json' },
  });
}

serve(async (req) => {
  try {
    if (webhookSecret) {
      const authHeader = req.headers.get('Authorization') ?? '';
      const expected = `Bearer ${webhookSecret}`;
      if (authHeader !== expected) {
        return unauthorized('Invalid webhook secret.');
      }
    }

    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ ok: false, error: 'Method not allowed' }), {
        status: 405,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const body = (await req.json()) as DispatchPayload;
    const items = Array.isArray(body.items) ? body.items : [];
    const recipientCount = items.reduce((sum, item) => {
      const recipients = Array.isArray(item.recipients) ? item.recipients.length : 0;
      return sum + recipients;
    }, 0);

    // Keep logs lightweight but useful for ops/debug.
    console.log(
      JSON.stringify({
        source: 'admin-push-webhook',
        channel: body.channel ?? null,
        created_at: body.created_at ?? null,
        events_count: items.length,
        recipients_count: recipientCount,
        event_ids: items.map((item) => item.id).filter(Boolean),
      }),
    );

    return new Response(
      JSON.stringify({
        ok: true,
        accepted_events: items.length,
        accepted_recipients: recipientCount,
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

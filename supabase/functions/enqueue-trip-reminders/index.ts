import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.8';
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL');
const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const dispatcherAuthToken = Deno.env.get('DISPATCHER_CRON_TOKEN') ?? '';

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

serve(async (req) => {
  try {
    if (dispatcherAuthToken) {
      const authHeader = req.headers.get('Authorization') ?? '';
      const expected = `Bearer ${dispatcherAuthToken}`;
      if (authHeader !== expected) {
        return unauthorized('Invalid dispatcher token.');
      }
    }

    const url = new URL(req.url);
    const dryRun = url.searchParams.get('dry_run') === 'true';
    const windowFromMinutes = Number(
      url.searchParams.get('window_from_minutes') ?? '55',
    );
    const windowToMinutes = Number(
      url.searchParams.get('window_to_minutes') ?? '65',
    );

    const { data, error } = await supabase.rpc('enqueue_trip_reminder_events', {
      window_from_minutes: windowFromMinutes,
      window_to_minutes: windowToMinutes,
      preview_only: dryRun,
    });

    if (error) {
      throw new Error(
        `enqueue_trip_reminder_events failed: ${error.message}`,
      );
    }

    return new Response(
      JSON.stringify({
        ok: true,
        dry_run: dryRun,
        result: data ?? {},
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

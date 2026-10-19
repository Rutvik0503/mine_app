// send-reengagement
// Daily job (pg_cron, see the setup note at the bottom of this file): a
// "come back" push to players who haven't opened the app for exactly 3 or
// 7 days. The phone's own "we miss you" reminder covers day 2; after that
// only the server can reach them. Each device is nudged at most once per
// step (device_tokens.last_reengaged_at).
//
// Not called by the app: verify_jwt is off and the request must carry the
// CRON_SECRET in the x-cron-secret header.

import { adminClient } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { PushMessage, sendPushToUser } from "../_shared/fcm.ts";

const MESSAGES: Record<number, PushMessage> = {
  3: {
    type: "reengagement",
    title: {
      en: "⛏️ Your miners are waiting",
      gu: "⛏️ તમારા miners રાહ જુએ છે",
      hi: "⛏️ आपके miners इंतज़ार कर रहे हैं",
    },
    body: {
      en: "3 days without mining! Come back - your free spins and free coins are ready.",
      gu: "3 દિવસથી mining બંધ છે! પાછા આવો - મફત spins અને મફત coins તૈયાર છે.",
      hi: "3 दिन से mining बंद है! वापस आएं - मुफ़्त spins और मुफ़्त coins तैयार हैं।",
    },
  },
  7: {
    type: "reengagement",
    title: {
      en: "🏆 Your farm misses you",
      gu: "🏆 તમારું ફાર્મ તમને યાદ કરે છે",
      hi: "🏆 आपका फार्म आपको याद करता है",
    },
    body: {
      en: "A week away - start a mining session today and get back on the leaderboard.",
      gu: "એક અઠવાડિયું થયું - આજે mining શરૂ કરો અને leaderboard પર પાછા આવો.",
      hi: "एक हफ्ता हो गया - आज mining शुरू करें और leaderboard पर वापस आएं।",
    },
  },
};

function dayOffset(days: number): string {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() - days);
  return d.toISOString().slice(0, 10);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const secret = Deno.env.get("CRON_SECRET");
    if (!secret || req.headers.get("x-cron-secret") !== secret) {
      return new Response("Forbidden", { status: 403 });
    }

    const admin = adminClient();
    const recentCutoff = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString();
    let sent = 0;

    for (const days of [3, 7]) {
      // streaks.last_completed_date moves every day the app is opened.
      const { data: idle } = await admin
        .from("streaks")
        .select("user_id")
        .eq("last_completed_date", dayOffset(days));
      for (const row of idle ?? []) {
        const { data: devices } = await admin
          .from("device_tokens")
          .select("id, last_reengaged_at")
          .eq("user_id", row.user_id);
        if (!devices || devices.length === 0) continue;
        if (devices.some((d) => d.last_reengaged_at && d.last_reengaged_at > recentCutoff)) continue;

        await sendPushToUser(admin, row.user_id, MESSAGES[days]);
        await admin
          .from("device_tokens")
          .update({ last_reengaged_at: new Date().toISOString() })
          .eq("user_id", row.user_id);
        sent++;
      }
    }

    return jsonResponse({ ok: true, sent });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "send-reengagement failed", 500);
  }
});

// Setup (run once in the SQL editor - kept out of migrations because it
// holds the secret):
//   select cron.schedule('send-reengagement', '30 12 * * *',  -- 6 PM IST
//     $$ select net.http_post(
//          url := 'https://<project-ref>.supabase.co/functions/v1/send-reengagement',
//          headers := '{"x-cron-secret": "<CRON_SECRET>"}'::jsonb) $$);

// grant-ad-reward
// Grants the reward for an opt-in rewarded ad, called after AdsService
// confirms the ad was watched to completion (same trust boundary as
// grant-ad-boost: the ad SDK's callback can't be verified server-side, so
// every reward here is small and capped).
//
//   { action: "status" }                         -> free coins / speed-ups left today
//   { action: "free_coins" }                     -> +FREE_COINS_AMOUNT coins
//   { action: "speed_up", session_id }           -> session finishes SPEED_UP_MINUTES sooner

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

const FREE_COINS_AMOUNT = 3;
const FREE_COINS_PER_DAY = 5;
const FREE_COINS_SOURCE = "ad_free_coins";

const SPEED_UP_MINUTES = 10;
// Per day across all sessions, so a player can spend them on whichever
// session they like.
const SPEED_UPS_PER_DAY = 5;
const SPEED_UP_KIND = "speed_up";

function utcDayStart(): string {
  const d = new Date();
  d.setUTCHours(0, 0, 0, 0);
  return d.toISOString();
}

// deno-lint-ignore no-explicit-any
async function speedUpsUsedToday(admin: any, userId: string): Promise<number> {
  const { count } = await admin
    .from("ad_reward_logs")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("kind", SPEED_UP_KIND)
    .gte("created_at", utcDayStart());
  return count ?? 0;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const action: string | undefined = body.action;

    if (action === "status" || action === "free_coins") {
      const { count } = await admin
        .from("reward_transactions")
        .select("id", { count: "exact", head: true })
        .eq("user_id", user.id)
        .eq("source", FREE_COINS_SOURCE)
        .gte("created_at", utcDayStart());
      const used = count ?? 0;

      if (action === "status") {
        return jsonResponse({
          ok: true,
          free_coins_left: Math.max(0, FREE_COINS_PER_DAY - used),
          free_coins_amount: FREE_COINS_AMOUNT,
          speed_ups_left: Math.max(0, SPEED_UPS_PER_DAY - (await speedUpsUsedToday(admin, user.id))),
        });
      }

      if (used >= FREE_COINS_PER_DAY) throw new Error("No free coins left today - come back tomorrow");
      const { error } = await admin.from("reward_transactions").insert({
        user_id: user.id,
        type: "ad_reward",
        amount: FREE_COINS_AMOUNT,
        source: FREE_COINS_SOURCE,
        status: "completed",
      });
      if (error) throw error;
      return jsonResponse({
        ok: true,
        coins: FREE_COINS_AMOUNT,
        free_coins_left: Math.max(0, FREE_COINS_PER_DAY - used - 1),
      });
    }

    if (action === "speed_up") {
      const sessionId: string | undefined = body.session_id;
      if (!sessionId) throw new Error("session_id is required");

      const { data: session, error: sessionError } = await admin
        .from("mining_sessions")
        .select("*")
        .eq("id", sessionId)
        .eq("user_id", user.id)
        .single();
      if (sessionError || !session) throw new Error("Mining session not found");
      if (session.status !== "active") throw new Error("This session has already ended");
      if (new Date(session.expected_end_at) <= new Date()) throw new Error("This session is already finished");
      const usedToday = await speedUpsUsedToday(admin, user.id);
      if (usedToday >= SPEED_UPS_PER_DAY) throw new Error("No speed-ups left today - come back tomorrow");

      // Shift both ends back so the session finishes sooner but keeps its
      // full duration - claim-mining pays hashrate x (end - start), so the
      // reward stays the same; the player just waits less.
      const shiftMs = SPEED_UP_MINUTES * 60 * 1000;
      const { data: updated, error: updateError } = await admin
        .from("mining_sessions")
        .update({
          started_at: new Date(new Date(session.started_at).getTime() - shiftMs).toISOString(),
          expected_end_at: new Date(new Date(session.expected_end_at).getTime() - shiftMs).toISOString(),
          ad_speedups_used: session.ad_speedups_used + 1,
        })
        .eq("id", session.id)
        .eq("status", "active")
        .eq("ad_speedups_used", session.ad_speedups_used) // guards a double tap / race
        .select("*")
        .single();
      if (updateError || !updated) throw new Error("Could not speed up - try again");

      await admin.from("ad_reward_logs").insert({ user_id: user.id, kind: SPEED_UP_KIND, reference_id: session.id });

      return jsonResponse({
        ok: true,
        session: updated,
        minutes: SPEED_UP_MINUTES,
        speed_ups_left: Math.max(0, SPEED_UPS_PER_DAY - usedToday - 1),
      });
    }

    throw new Error("Unknown action");
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "grant-ad-reward failed", 400);
  }
});

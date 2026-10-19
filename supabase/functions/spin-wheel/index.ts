// spin-wheel
// Fortune wheel with segments 0-8. The result is picked here, never on the
// device, and paid out as coins (a 'spin' reward_transactions row).
//
// Body: { action: "status" }           -> prize table + spins left today
//       { action: "spin", source }     -> spin once; source "free" | "ad"
//
// Free spins reset every UTC day. Ad spins are capped per day too: the
// rewarded-ad callback is a client-side signal we can't verify (same caveat
// as grant-ad-boost), so the cap is what bounds abuse.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

const FREE_SPINS_PER_DAY = 3;
const AD_SPINS_PER_DAY = 5;

// Coins per segment and its relative odds. Winning numbers are 1, 3, 5, 7;
// the big prizes are rare. Weights sum to 100; expected value is 5.4
// coins per spin.
const SEGMENTS: { segment: number; reward: number; weight: number }[] = [
  { segment: 0, reward: 0, weight: 16 },
  { segment: 1, reward: 10, weight: 18 },
  { segment: 2, reward: 0, weight: 14 },
  { segment: 3, reward: 5, weight: 22 },
  { segment: 4, reward: 0, weight: 12 },
  { segment: 5, reward: 25, weight: 6 },
  { segment: 6, reward: 0, weight: 8 },
  { segment: 7, reward: 50, weight: 2 },
  { segment: 8, reward: 0, weight: 2 },
];

function pickSegment() {
  const total = SEGMENTS.reduce((s, x) => s + x.weight, 0);
  const buf = new Uint32Array(1);
  crypto.getRandomValues(buf);
  let roll = (buf[0] / 0x100000000) * total;
  for (const s of SEGMENTS) {
    if (roll < s.weight) return s;
    roll -= s.weight;
  }
  return SEGMENTS[0];
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const action: string = body.action ?? "status";

    const dayStart = new Date();
    dayStart.setUTCHours(0, 0, 0, 0);
    const { data: today } = await admin
      .from("spin_logs")
      .select("source")
      .eq("user_id", user.id)
      .gte("created_at", dayStart.toISOString());
    const freeUsed = (today ?? []).filter((s) => s.source === "free").length;
    const adUsed = (today ?? []).filter((s) => s.source === "ad").length;

    const status = () => ({
      free_spins_left: Math.max(0, FREE_SPINS_PER_DAY - freeUsed),
      ad_spins_left: Math.max(0, AD_SPINS_PER_DAY - adUsed),
      prizes: SEGMENTS.map(({ segment, reward }) => ({ segment, reward })),
    });

    if (action === "status") return jsonResponse({ ok: true, ...status() });
    if (action !== "spin") throw new Error("Unknown action");

    const source: string = body.source;
    if (source === "free") {
      if (freeUsed >= FREE_SPINS_PER_DAY) throw new Error("No free spins left today");
    } else if (source === "ad") {
      if (adUsed >= AD_SPINS_PER_DAY) throw new Error("No ad spins left today");
    } else {
      throw new Error("source must be 'free' or 'ad'");
    }

    const result = pickSegment();

    const { data: log, error: logError } = await admin
      .from("spin_logs")
      .insert({ user_id: user.id, source, segment: result.segment, reward: result.reward })
      .select("id")
      .single();
    if (logError) throw logError;

    if (result.reward > 0) {
      const { error: rewardError } = await admin.from("reward_transactions").insert({
        user_id: user.id,
        type: "spin",
        amount: result.reward,
        source: `spin_${source}`,
        reference_id: log.id,
        status: "completed",
      });
      if (rewardError) throw rewardError;
    }

    if (source === "free") {
      return jsonResponse({ ok: true, segment: result.segment, reward: result.reward, ...status(), free_spins_left: Math.max(0, FREE_SPINS_PER_DAY - freeUsed - 1) });
    }
    return jsonResponse({ ok: true, segment: result.segment, reward: result.reward, ...status(), ad_spins_left: Math.max(0, AD_SPINS_PER_DAY - adUsed - 1) });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "spin-wheel failed", 400);
  }
});

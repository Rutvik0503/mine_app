// claim-mining
// Validates the session belongs to the caller, is due, and hasn't already
// been claimed (idempotent - see docs section 45), then grants the reward
// inside a single transaction-like sequence.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { bumpMissionProgress } from "../_shared/missions.ts";
import { activateReferralIfEligible } from "../_shared/referral.ts";

const AD_BONUS_SOURCE = "mining_ad_bonus";
const MAX_AD_BONUSES_PER_DAY = 5;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const sessionId: string | undefined = body.session_id;
    // Set after the player watched a rewarded ad for "Claim 2x". The ad
    // callback can't be verified server-side, so the bonus is capped per day.
    const adBonus: boolean = body.ad_bonus === true;
    if (!sessionId) throw new Error("session_id is required");

    const { data: session, error: sessionError } = await admin
      .from("mining_sessions")
      .select("*")
      .eq("id", sessionId)
      .eq("user_id", user.id)
      .single();
    if (sessionError || !session) throw new Error("Mining session not found");

    if (session.status !== "active") {
      throw new Error("This reward has already been claimed");
    }

    const now = new Date();
    const expectedEnd = new Date(session.expected_end_at);
    if (now < expectedEnd) {
      throw new Error("Mining session is not finished yet");
    }

    const startedAt = new Date(session.started_at);
    const durationHours = (expectedEnd.getTime() - startedAt.getTime()) / (1000 * 60 * 60);
    const reward = Number(session.hashrate_snapshot) * durationHours * Number(session.reward_rate_snapshot);
    const roundedReward = Math.round(reward * 100) / 100;

    const { data: updated, error: updateError } = await admin
      .from("mining_sessions")
      .update({ status: "completed", completed_at: now.toISOString(), calculated_reward: roundedReward })
      .eq("id", session.id)
      .eq("status", "active") // second guard against a race with another claim
      .select("id");
    if (updateError) throw updateError;
    // If a concurrent request already flipped status away from 'active',
    // the filtered update above matches zero rows - stop here so the
    // reward isn't granted twice for one session.
    if (!updated || updated.length === 0) {
      throw new Error("This reward has already been claimed");
    }

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "mining",
      amount: roundedReward,
      source: "mining_session",
      reference_id: session.id,
      status: "completed",
    });

    let bonus = 0;
    if (adBonus && roundedReward > 0) {
      const dayStart = new Date();
      dayStart.setUTCHours(0, 0, 0, 0);
      const { count } = await admin
        .from("reward_transactions")
        .select("id", { count: "exact", head: true })
        .eq("user_id", user.id)
        .eq("source", AD_BONUS_SOURCE)
        .gte("created_at", dayStart.toISOString());
      if ((count ?? 0) < MAX_AD_BONUSES_PER_DAY) {
        bonus = roundedReward;
        await admin.from("reward_transactions").insert({
          user_id: user.id,
          type: "mining",
          amount: bonus,
          source: AD_BONUS_SOURCE,
          reference_id: session.id,
          status: "completed",
        });
      }
    }

    await bumpMissionProgress(admin, user.id, "claim_mining");
    await activateReferralIfEligible(admin, user.id);

    return jsonResponse({ ok: true, reward: roundedReward + bonus, ad_bonus: bonus });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "claim-mining failed", 400);
  }
});

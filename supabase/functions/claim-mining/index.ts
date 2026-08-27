// claim-mining
// Validates the session belongs to the caller, is due, and hasn't already
// been claimed (idempotent - see docs section 45), then grants the reward
// inside a single transaction-like sequence.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { bumpMissionProgress } from "../_shared/missions.ts";
import { activateReferralIfEligible } from "../_shared/referral.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const sessionId: string | undefined = body.session_id;
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

    const { error: updateError } = await admin
      .from("mining_sessions")
      .update({ status: "completed", completed_at: now.toISOString(), calculated_reward: roundedReward })
      .eq("id", session.id)
      .eq("status", "active"); // second guard against a race with another claim
    if (updateError) throw updateError;

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "mining",
      amount: roundedReward,
      source: "mining_session",
      reference_id: session.id,
      status: "completed",
    });

    await bumpMissionProgress(admin, user.id, "claim_mining");
    await activateReferralIfEligible(admin, user.id);

    return jsonResponse({ ok: true, reward: roundedReward });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "claim-mining failed", 400);
  }
});

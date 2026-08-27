// start-mining
// Validates the user/farm/machines, computes the current hashrate and
// reward rate server-side, and opens a new mining_sessions row.
// See docs section 11 "Start Mining Flow" and section 14 "Hashrate System".

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { bumpMissionProgress } from "../_shared/missions.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);

    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("id, level, status")
      .eq("id", user.id)
      .single();
    if (profileError || !profile) throw new Error("Profile not found");
    if (profile.status !== "active") throw new Error("Account is not active");

    const { data: farm, error: farmError } = await admin
      .from("farms")
      .select("id, multiplier")
      .eq("user_id", user.id)
      .single();
    if (farmError || !farm) throw new Error("Farm not found");

    const { data: existingSession } = await admin
      .from("mining_sessions")
      .select("id")
      .eq("user_id", user.id)
      .eq("status", "active")
      .maybeSingle();
    if (existingSession) throw new Error("A mining session is already active");

    const { data: machines } = await admin
      .from("user_machines")
      .select("current_hashrate")
      .eq("user_id", user.id)
      .eq("status", "active");

    const machineHashrate = (machines ?? []).reduce(
      (sum, m) => sum + Number(m.current_hashrate ?? 0),
      0,
    );

    const { data: activeBoosts } = await admin
      .from("user_boosts")
      .select("boosts(multiplier, type)")
      .eq("user_id", user.id)
      .eq("status", "active")
      .gt("expires_at", new Date().toISOString());

    const boostMultiplier = (activeBoosts ?? []).reduce((mult: number, ub: any) => {
      const boost = ub.boosts;
      if (boost?.type === "mining" || boost?.type === "efficiency") {
        return mult * Number(boost.multiplier ?? 1);
      }
      return mult;
    }, 1);

    const userMultiplier = 1 + Math.min(profile.level, 100) * 0.005; // +0.5%/level, capped

    const finalHashrate = machineHashrate * Number(farm.multiplier) * userMultiplier * boostMultiplier;

    const { data: config } = await admin
      .from("app_config")
      .select("mining_rate, max_session_minutes, maintenance_mode")
      .limit(1)
      .maybeSingle();

    if (config?.maintenance_mode) throw new Error("Mining is temporarily disabled for maintenance");

    const rewardRate = Number(config?.mining_rate ?? 1.0);
    const sessionMinutes = Number(config?.max_session_minutes ?? 60);

    const startedAt = new Date();
    const expectedEndAt = new Date(startedAt.getTime() + sessionMinutes * 60 * 1000);

    const { data: session, error: sessionError } = await admin
      .from("mining_sessions")
      .insert({
        user_id: user.id,
        farm_id: farm.id,
        started_at: startedAt.toISOString(),
        expected_end_at: expectedEndAt.toISOString(),
        hashrate_snapshot: finalHashrate,
        reward_rate_snapshot: rewardRate,
        status: "active",
      })
      .select()
      .single();
    if (sessionError) throw sessionError;

    await admin.from("profiles").update({ total_hashrate: finalHashrate }).eq("id", user.id);

    await bumpMissionProgress(admin, user.id, "start_mining");

    return jsonResponse({ ok: true, session });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "start-mining failed", 400);
  }
});

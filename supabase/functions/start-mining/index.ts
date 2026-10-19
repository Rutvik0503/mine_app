// start-mining
// Validates the user/farm/machines, computes the current hashrate and
// reward rate server-side, and opens a new mining_sessions row.
// See docs section 11 "Start Mining Flow" and section 14 "Hashrate System".

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { activeMachineFilter } from "../_shared/hashrate.ts";
import { bumpMissionProgress } from "../_shared/missions.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    // Optional: the user_machines ids to mine with. Omitted = every active
    // machine (older app builds).
    const requestedIds: string[] | undefined = Array.isArray(body.machine_ids)
      ? body.machine_ids.filter((id: unknown) => typeof id === "string")
      : undefined;

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

    const { data: activeMachines } = await admin
      .from("user_machines")
      .select("id, current_hashrate")
      .eq("user_id", user.id)
      .eq("status", "active")
      .or(activeMachineFilter()); // expired rentals stop mining

    let machines = activeMachines ?? [];
    if (requestedIds !== undefined) {
      const wanted = new Set(requestedIds);
      if (wanted.size === 0) throw new Error("Select at least one miner");
      machines = machines.filter((m) => wanted.has(m.id));
      // Only the caller's own, still-running machines can be picked.
      if (machines.length !== wanted.size) {
        throw new Error("Some selected miners are no longer available - refresh and try again");
      }
    }

    const machineHashrate = machines.reduce(
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
      if (boost?.type === "mining" || boost?.type === "efficiency" || boost?.type === "lucky") {
        return mult * Number(boost.multiplier ?? 1);
      }
      return mult;
    }, 1);

    // A "speed" boost shortens the session instead of multiplying the
    // reward rate - same total hashrate, less waiting.
    const speedMultiplier = (activeBoosts ?? []).reduce((mult: number, ub: any) => {
      const boost = ub.boosts;
      return boost?.type === "speed" ? mult * Number(boost.multiplier ?? 1) : mult;
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
    const baseSessionMinutes = Number(config?.max_session_minutes ?? 60);
    const sessionMinutes = Math.max(5, Math.round(baseSessionMinutes / speedMultiplier));

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
        machine_ids: machines.map((m) => m.id),
        status: "active",
      })
      .select()
      .single();
    if (sessionError) {
      // 23505 = unique_violation on uq_mining_sessions_one_active_per_user -
      // a concurrent request won the race and inserted first. Same friendly
      // message as the earlier checked case, not a raw DB error.
      if (sessionError.code === "23505") {
        throw new Error("A mining session is already active");
      }
      throw sessionError;
    }

    await admin.from("profiles").update({ total_hashrate: finalHashrate }).eq("id", user.id);

    await bumpMissionProgress(admin, user.id, "start_mining");

    return jsonResponse({ ok: true, session });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "start-mining failed", 400);
  }
});

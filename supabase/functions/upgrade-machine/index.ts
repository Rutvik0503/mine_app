// upgrade-machine
// Validates ownership, level cap and balance, then applies the upgrade and
// deducts the cost inside one sequence (docs section 19).

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { hashrateForLevel, recomputeTotalHashrate, upgradeCostForLevel } from "../_shared/hashrate.ts";
import { bumpMissionProgress } from "../_shared/missions.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const userMachineId: string | undefined = body.user_machine_id;
    if (!userMachineId) throw new Error("user_machine_id is required");

    const { data: userMachine, error: umError } = await admin
      .from("user_machines")
      .select("*, machines(base_hashrate, max_level, base_efficiency)")
      .eq("id", userMachineId)
      .eq("user_id", user.id)
      .single();
    if (umError || !userMachine) throw new Error("Machine not found");

    const maxLevel = userMachine.machines?.max_level ?? 10;
    if (userMachine.level >= maxLevel) throw new Error("Machine is already at maximum level");

    const nextLevel = userMachine.level + 1;
    const cost = upgradeCostForLevel(nextLevel);

    const { data: txns } = await admin
      .from("reward_transactions")
      .select("amount")
      .eq("user_id", user.id)
      .eq("status", "completed");
    const balance = (txns ?? []).reduce((sum, t) => sum + Number(t.amount ?? 0), 0);
    if (balance < cost) throw new Error("Not enough balance to upgrade this machine");

    const newHashrate = hashrateForLevel(userMachine.machines?.base_hashrate ?? 1, nextLevel);
    const newEfficiency = Math.min((userMachine.machines?.base_efficiency ?? 0.8) + 0.01 * nextLevel, 0.98);

    const { error: updateError } = await admin
      .from("user_machines")
      .update({
        level: nextLevel,
        current_hashrate: newHashrate,
        current_efficiency: newEfficiency,
        updated_at: new Date().toISOString(),
      })
      .eq("id", userMachine.id);
    if (updateError) throw updateError;

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "adjustment",
      amount: -cost,
      source: "upgrade_machine",
      reference_id: userMachine.id,
      status: "completed",
    });

    const totalHashrate = await recomputeTotalHashrate(admin, user.id);
    await bumpMissionProgress(admin, user.id, "upgrade_machine");

    return jsonResponse({
      ok: true,
      level: nextLevel,
      hashrate: newHashrate,
      efficiency: newEfficiency,
      cost,
      total_hashrate: totalHashrate,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "upgrade-machine failed", 400);
  }
});

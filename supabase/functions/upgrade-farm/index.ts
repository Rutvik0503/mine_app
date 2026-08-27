// upgrade-farm
// Increases the user's farm level, multiplier and machine capacity.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { farmUpgradeCostForLevel, recomputeTotalHashrate } from "../_shared/hashrate.ts";

const MAX_FARM_LEVEL = 50;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);

    const { data: farm, error: farmError } = await admin
      .from("farms")
      .select("*")
      .eq("user_id", user.id)
      .single();
    if (farmError || !farm) throw new Error("Farm not found");
    if (farm.level >= MAX_FARM_LEVEL) throw new Error("Farm is already at maximum level");

    const nextLevel = farm.level + 1;
    const cost = farmUpgradeCostForLevel(nextLevel);

    const { data: txns } = await admin
      .from("reward_transactions")
      .select("amount")
      .eq("user_id", user.id)
      .eq("status", "completed");
    const balance = (txns ?? []).reduce((sum, t) => sum + Number(t.amount ?? 0), 0);
    if (balance < cost) throw new Error("Not enough balance to upgrade the farm");

    const newMultiplier = Math.round((Number(farm.multiplier) + 0.05) * 100) / 100;
    const newCapacity = farm.capacity + (nextLevel % 2 === 0 ? 1 : 0);

    const { error: updateError } = await admin
      .from("farms")
      .update({
        level: nextLevel,
        multiplier: newMultiplier,
        capacity: newCapacity,
        updated_at: new Date().toISOString(),
      })
      .eq("id", farm.id);
    if (updateError) throw updateError;

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "adjustment",
      amount: -cost,
      source: "upgrade_farm",
      reference_id: farm.id,
      status: "completed",
    });

    const totalHashrate = await recomputeTotalHashrate(admin, user.id);

    return jsonResponse({
      ok: true,
      level: nextLevel,
      multiplier: newMultiplier,
      capacity: newCapacity,
      cost,
      total_hashrate: totalHashrate,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "upgrade-farm failed", 400);
  }
});

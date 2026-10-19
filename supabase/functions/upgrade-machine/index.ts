// upgrade-machine
// Validates ownership, level cap and balance, then applies the upgrade and
// deducts the cost inside one sequence (docs section 19). The money path
// (create-razorpay-order kind "machine_upgrade" + razorpay-webhook) ends in
// the same applyMachineUpgrade.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { applyMachineUpgrade, nextMachineUpgrade } from "../_shared/machine_upgrade.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const userMachineId: string | undefined = body.user_machine_id;
    if (!userMachineId) throw new Error("user_machine_id is required");

    const { cost } = await nextMachineUpgrade(admin, user.id, userMachineId);

    const { data: txns } = await admin
      .from("reward_transactions")
      .select("amount")
      .eq("user_id", user.id)
      .eq("status", "completed");
    const balance = (txns ?? []).reduce((sum, t) => sum + Number(t.amount ?? 0), 0);
    if (balance < cost) throw new Error("Not enough balance to upgrade this machine");

    const result = await applyMachineUpgrade(admin, user.id, userMachineId);

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "adjustment",
      amount: -cost,
      source: "upgrade_machine",
      reference_id: userMachineId,
      status: "completed",
    });

    return jsonResponse({
      ok: true,
      level: result.level,
      hashrate: result.hashrate,
      efficiency: result.efficiency,
      cost,
      total_hashrate: result.totalHashrate,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "upgrade-machine failed", 400);
  }
});

// rent-machine
// Rents a store miner for one of its plans, paid with coins (the user's
// completed reward_transactions balance). The money path goes through
// create-razorpay-order (kind: "machine_rental") + razorpay-webhook instead;
// both end in grantMachineRental so the outcome is identical.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { assertCanRent, grantMachineRental } from "../_shared/rental.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const planId: string | undefined = body.plan_id;
    if (!planId) throw new Error("plan_id is required");

    const { data: plan, error: planError } = await admin
      .from("machine_plans")
      .select("id, machine_id, price_coins")
      .eq("id", planId)
      .eq("is_active", true)
      .single();
    if (planError || !plan) throw new Error("Plan not found");

    await assertCanRent(admin, user.id, plan.machine_id);

    const cost = Number(plan.price_coins);
    const { data: txns } = await admin
      .from("reward_transactions")
      .select("amount")
      .eq("user_id", user.id)
      .eq("status", "completed");
    const balance = (txns ?? []).reduce((sum, t) => sum + Number(t.amount ?? 0), 0);
    if (balance < cost) throw new Error("Not enough coins for this plan");

    // Debit first: if granting fails afterwards the user is refunded below
    // rather than getting a free machine on a retry race.
    const { data: debit, error: debitError } = await admin
      .from("reward_transactions")
      .insert({
        user_id: user.id,
        type: "adjustment",
        amount: -cost,
        source: "machine_rental",
        reference_id: plan.id,
        status: "completed",
      })
      .select("id")
      .single();
    if (debitError) throw debitError;

    try {
      const result = await grantMachineRental(admin, user.id, plan.id);
      return jsonResponse({ ok: true, cost, user_machine_id: result.userMachineId, expires_at: result.expiresAt });
    } catch (grantError) {
      await admin.from("reward_transactions").update({ status: "failed" }).eq("id", debit.id);
      throw grantError;
    }
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "rent-machine failed", 400);
  }
});

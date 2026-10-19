// create-razorpay-order
// Creates a Razorpay Order and records a `pending` purchases row. The
// actual point grant / session extension / farm upgrade happens in
// razorpay-webhook once Razorpay confirms the payment - never here, since a
// client can close the app mid-payment.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { farmUpgradeCostForLevel } from "../_shared/hashrate.ts";
import { nextMachineUpgrade } from "../_shared/machine_upgrade.ts";
import { assertCanRent } from "../_shared/rental.ts";

const RAZORPAY_KEY_ID = Deno.env.get("RAZORPAY_KEY_ID")!;
const RAZORPAY_KEY_SECRET = Deno.env.get("RAZORPAY_KEY_SECRET")!;
const AUTH_HEADER = `Basic ${btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`)}`;

// Points -> paise, matching the Starter Pack's rate (500 pts / Rs.99) - the
// same "price per point" a player already gets buying the smallest pack, so
// a one-off farm-upgrade purchase never undercuts the Store's own pricing.
const PAISE_PER_POINT = 9900 / 500;
const MIN_ORDER_PAISE = 1000; // Rs.10 floor so a cheap early upgrade isn't a sub-Rs.1 Razorpay order

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const packageId: string | undefined = body.package_id;
    const sessionId: string | undefined = body.session_id;
    const kind: string | undefined = body.kind;

    if (kind === "farm_upgrade") {
      const { data: farm, error: farmError } = await admin
        .from("farms")
        .select("id, level")
        .eq("user_id", user.id)
        .single();
      if (farmError || !farm) throw new Error("Farm not found");

      const cost = farmUpgradeCostForLevel(farm.level + 1);
      const amountPaise = Math.max(MIN_ORDER_PAISE, Math.ceil(cost * PAISE_PER_POINT));

      const orderRes = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: AUTH_HEADER },
        body: JSON.stringify({
          amount: amountPaise,
          currency: "INR",
          notes: { user_id: user.id, kind: "farm_upgrade", target_level: String(farm.level + 1) },
        }),
      });
      const order = await orderRes.json();
      if (!orderRes.ok) throw new Error(order?.error?.description ?? "Razorpay order creation failed");

      const { error: insertError } = await admin.from("purchases").insert({
        user_id: user.id,
        razorpay_order_id: order.id,
        amount_cents: amountPaise,
        currency: "inr",
        points_granted: 0,
        status: "pending",
        kind: "farm_upgrade",
      });
      if (insertError) throw insertError;

      return jsonResponse({ ok: true, order_id: order.id, amount: order.amount, currency: order.currency });
    }

    if (kind === "machine_upgrade") {
      const userMachineId: string | undefined = body.user_machine_id;
      if (!userMachineId) throw new Error("user_machine_id is required");
      const { nextLevel, cost } = await nextMachineUpgrade(admin, user.id, userMachineId);
      const amountPaise = Math.max(MIN_ORDER_PAISE, Math.ceil(cost * PAISE_PER_POINT));

      const orderRes = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: AUTH_HEADER },
        body: JSON.stringify({
          amount: amountPaise,
          currency: "INR",
          notes: {
            user_id: user.id,
            kind: "machine_upgrade",
            user_machine_id: userMachineId,
            target_level: String(nextLevel),
          },
        }),
      });
      const order = await orderRes.json();
      if (!orderRes.ok) throw new Error(order?.error?.description ?? "Razorpay order creation failed");

      const { error: insertError } = await admin.from("purchases").insert({
        user_id: user.id,
        razorpay_order_id: order.id,
        amount_cents: amountPaise,
        currency: "inr",
        points_granted: 0,
        status: "pending",
        kind: "machine_upgrade",
        user_machine_id: userMachineId,
      });
      if (insertError) throw insertError;

      return jsonResponse({ ok: true, order_id: order.id, amount: order.amount, currency: order.currency });
    }

    if (kind === "machine_rental") {
      const planId: string | undefined = body.plan_id;
      if (!planId) throw new Error("plan_id is required");
      const { data: plan, error: planError } = await admin
        .from("machine_plans")
        .select("id, machine_id, price_paise, label")
        .eq("id", planId)
        .eq("is_active", true)
        .single();
      if (planError || !plan) throw new Error("Plan not found");

      // Checked before taking money - razorpay-webhook grants regardless.
      await assertCanRent(admin, user.id, plan.machine_id);

      const orderRes = await fetch("https://api.razorpay.com/v1/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: AUTH_HEADER },
        body: JSON.stringify({
          amount: plan.price_paise,
          currency: "INR",
          notes: { user_id: user.id, kind: "machine_rental", plan_id: plan.id },
        }),
      });
      const order = await orderRes.json();
      if (!orderRes.ok) throw new Error(order?.error?.description ?? "Razorpay order creation failed");

      const { error: insertError } = await admin.from("purchases").insert({
        user_id: user.id,
        razorpay_order_id: order.id,
        amount_cents: plan.price_paise,
        currency: "inr",
        points_granted: 0,
        status: "pending",
        kind: "machine_rental",
        plan_id: plan.id,
      });
      if (insertError) throw insertError;

      return jsonResponse({ ok: true, order_id: order.id, amount: order.amount, currency: order.currency });
    }

    if (!packageId) throw new Error("package_id is required");

    const { data: pkg, error: pkgError } = await admin
      .from("store_packages")
      .select("*")
      .eq("id", packageId)
      .eq("is_active", true)
      .single();
    if (pkgError || !pkg) throw new Error("Package not found");

    if (pkg.kind === "session_extension") {
      if (!sessionId) throw new Error("session_id is required for a session_extension package");
      const { data: session, error: sessionErr } = await admin
        .from("mining_sessions")
        .select("id, status")
        .eq("id", sessionId)
        .eq("user_id", user.id)
        .single();
      if (sessionErr || !session) throw new Error("Mining session not found");
      if (session.status !== "active") throw new Error("This session has already ended");
    }

    const orderRes = await fetch("https://api.razorpay.com/v1/orders", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: AUTH_HEADER },
      body: JSON.stringify({
        amount: pkg.price_cents, // smallest currency unit (paise for INR)
        currency: pkg.currency.toUpperCase(),
        notes: { user_id: user.id, package_id: pkg.id, points: String(pkg.points) },
      }),
    });
    const order = await orderRes.json();
    if (!orderRes.ok) {
      throw new Error(order?.error?.description ?? "Razorpay order creation failed");
    }

    const { error: insertError } = await admin.from("purchases").insert({
      user_id: user.id,
      package_id: pkg.id,
      razorpay_order_id: order.id,
      amount_cents: pkg.price_cents,
      currency: pkg.currency,
      points_granted: pkg.points,
      status: "pending",
      kind: pkg.kind,
      session_id: pkg.kind === "session_extension" ? sessionId : null,
    });
    if (insertError) throw insertError;

    return jsonResponse({
      ok: true,
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "create-razorpay-order failed", 400);
  }
});

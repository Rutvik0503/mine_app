// razorpay-webhook
// Called by Razorpay directly (not the Flutter app), so it carries no
// Supabase JWT - auth is the X-Razorpay-Signature header instead (HMAC
// SHA256 of the raw body with the webhook secret; see config.toml,
// verify_jwt = false for this function only). This is the ONLY place a
// purchase actually grants points, and it's idempotent: a purchases row
// already 'succeeded' is never re-granted, even if Razorpay retries the
// event.

import { adminClient } from "../_shared/client.ts";
import { corsHeaders } from "../_shared/cors.ts";
import { recomputeTotalHashrate } from "../_shared/hashrate.ts";
import { applyMachineUpgrade } from "../_shared/machine_upgrade.ts";
import { grantMachineRental } from "../_shared/rental.ts";

const WEBHOOK_SECRET = Deno.env.get("RAZORPAY_WEBHOOK_SECRET")!;

async function verifySignature(body: string, signature: string): Promise<boolean> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(WEBHOOK_SECRET),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const mac = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  const expected = Array.from(new Uint8Array(mac))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return expected === signature;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  const signature = req.headers.get("X-Razorpay-Signature");
  const body = await req.text();

  if (!signature || !(await verifySignature(body, signature))) {
    console.error("Razorpay signature verification failed");
    return new Response("Invalid signature", { status: 400 });
  }

  const event = JSON.parse(body);
  const admin = adminClient();

  try {
    if (event.event === "payment.captured") {
      const payment = event.payload.payment.entity;
      const orderId: string = payment.order_id;
      const paymentId: string = payment.id;

      const { data: purchase } = await admin
        .from("purchases")
        .select("*")
        .eq("razorpay_order_id", orderId)
        .maybeSingle();

      // 'failed' is still capturable: Razorpay lets the user retry on the same
      // order after a failed attempt (e.g. an international card declined,
      // then a domestic card succeeds), and payment.failed for the first
      // attempt has already flipped the row to 'failed' by then.
      if (purchase && (purchase.status === "pending" || purchase.status === "failed")) {
        const { data: updated, error: updateError } = await admin
          .from("purchases")
          .update({
            status: "succeeded",
            razorpay_payment_id: paymentId,
            completed_at: new Date().toISOString(),
          })
          .eq("id", purchase.id)
          .in("status", ["pending", "failed"]) // guards against a duplicate webhook delivery
          .select("id");
        if (updateError) throw updateError;

        if (updated && updated.length > 0) {
          if (purchase.kind === "session_extension" && purchase.session_id) {
            const { data: session } = await admin
              .from("mining_sessions")
              .select("expected_end_at, status")
              .eq("id", purchase.session_id)
              .maybeSingle();
            // Extend from "now" if the session already finished waiting to be
            // claimed, otherwise stack onto the existing expected_end_at.
            if (session && session.status === "active") {
              const base = new Date(session.expected_end_at) > new Date()
                ? new Date(session.expected_end_at)
                : new Date();
              const minutes = purchase.package_id
                ? (
                    await admin
                      .from("store_packages")
                      .select("extension_minutes")
                      .eq("id", purchase.package_id)
                      .maybeSingle()
                  ).data?.extension_minutes ?? 60
                : 60;
              const newEndAt = new Date(base.getTime() + minutes * 60 * 1000);
              await admin
                .from("mining_sessions")
                .update({ expected_end_at: newEndAt.toISOString() })
                .eq("id", purchase.session_id)
                .eq("status", "active");
            }
          } else if (purchase.kind === "machine_upgrade" && purchase.user_machine_id) {
            await applyMachineUpgrade(admin, purchase.user_id, purchase.user_machine_id);
            await admin.from("reward_transactions").insert({
              user_id: purchase.user_id,
              type: "adjustment",
              amount: 0,
              source: "razorpay_machine_upgrade",
              reference_id: purchase.id,
              status: "completed",
            });
          } else if (purchase.kind === "machine_rental" && purchase.plan_id) {
            await grantMachineRental(admin, purchase.user_id, purchase.plan_id);
          } else if (purchase.kind === "farm_upgrade") {
            const { data: farm } = await admin
              .from("farms")
              .select("id, level, multiplier, capacity")
              .eq("user_id", purchase.user_id)
              .maybeSingle();
            if (farm) {
              const nextLevel = farm.level + 1;
              const newMultiplier = Math.round((Number(farm.multiplier) + 0.05) * 100) / 100;
              const newCapacity = farm.capacity + (nextLevel % 2 === 0 ? 1 : 0);
              await admin
                .from("farms")
                .update({
                  level: nextLevel,
                  multiplier: newMultiplier,
                  capacity: newCapacity,
                  updated_at: new Date().toISOString(),
                })
                .eq("id", farm.id);
              await recomputeTotalHashrate(admin, purchase.user_id);
              await admin.from("reward_transactions").insert({
                user_id: purchase.user_id,
                type: "adjustment",
                amount: 0,
                source: "razorpay_farm_upgrade",
                reference_id: purchase.id,
                status: "completed",
              });
            }
          } else {
            await admin.from("reward_transactions").insert({
              user_id: purchase.user_id,
              type: "purchase",
              amount: purchase.points_granted,
              source: "razorpay",
              reference_id: purchase.id,
              status: "completed",
            });
          }
        }
      }
    } else if (event.event === "payment.failed") {
      const payment = event.payload.payment.entity;
      await admin
        .from("purchases")
        .update({ status: "failed" })
        .eq("razorpay_order_id", payment.order_id)
        .eq("status", "pending");
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("razorpay-webhook handling failed:", e);
    return new Response("Webhook handler error", { status: 500 });
  }
});

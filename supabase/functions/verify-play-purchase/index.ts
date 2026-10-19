// verify-play-purchase
// Called by the app after Google Play reports a purchase. Checks the
// purchase token with the Google Play Developer API, grants the package
// (coins or Extra Mining Time) exactly once, then consumes it so it can be
// bought again. The app never grants anything itself.
//
// Idempotent: purchases.play_purchase_token is unique, so a retry (app
// restarted mid-flow, network drop) returns ok without granting twice.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { consumeProductPurchase, getProductPurchase } from "../_shared/google_play.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const productId: string | undefined = body.product_id;
    const token: string | undefined = body.purchase_token;
    const sessionId: string | undefined = body.session_id;
    if (!productId || !token) throw new Error("product_id and purchase_token are required");

    const { data: existing } = await admin
      .from("purchases")
      .select("id, user_id, status")
      .eq("play_purchase_token", token)
      .maybeSingle();
    if (existing) {
      if (existing.user_id !== user.id) throw new Error("This purchase belongs to another account");
      // Already granted - make sure it's consumed, then report success.
      await consumeProductPurchase(productId, token).catch((e) => console.warn(e.message));
      return jsonResponse({ ok: true, already_granted: true });
    }

    const { data: pkg, error: pkgError } = await admin
      .from("store_packages")
      .select("*")
      .eq("play_product_id", productId)
      .maybeSingle();
    if (pkgError || !pkg) throw new Error("Unknown product");

    const purchase = await getProductPurchase(productId, token);
    if (purchase.purchaseState === 2) throw new Error("Payment is still pending");
    if (purchase.purchaseState !== 0) throw new Error("This purchase was cancelled");
    if (purchase.consumptionState === 1) throw new Error("This purchase was already used");
    // The app passes the Supabase user id as Play's obfuscated account id,
    // so a token can't be replayed onto someone else's account.
    if (purchase.obfuscatedExternalAccountId && purchase.obfuscatedExternalAccountId !== user.id) {
      throw new Error("This purchase belongs to another account");
    }

    // Insert first: the unique token makes a concurrent retry fail here
    // instead of granting twice.
    const { data: row, error: insertError } = await admin
      .from("purchases")
      .insert({
        user_id: user.id,
        package_id: pkg.id,
        provider: "google_play",
        play_purchase_token: token,
        play_order_id: purchase.orderId ?? null,
        amount_cents: pkg.price_cents,
        currency: pkg.currency,
        points_granted: pkg.kind === "points" ? pkg.points : 0,
        status: "succeeded",
        completed_at: new Date().toISOString(),
        kind: pkg.kind,
      })
      .select("id")
      .single();
    if (insertError) {
      if (insertError.code === "23505") return jsonResponse({ ok: true, already_granted: true });
      throw insertError;
    }

    if (pkg.kind === "session_extension") {
      await extendSession(admin, user.id, sessionId, Number(pkg.extension_minutes ?? 60), row.id, pkg.price_cents);
    } else {
      await admin.from("reward_transactions").insert({
        user_id: user.id,
        type: "purchase",
        amount: pkg.points,
        source: "google_play",
        reference_id: row.id,
        status: "completed",
      });
    }

    // Granted - a failed consume only means the next verify call retries it.
    await consumeProductPurchase(productId, token).catch((e) => console.warn(e.message));

    return jsonResponse({ ok: true, granted: true, kind: pkg.kind });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "verify-play-purchase failed", 400);
  }
});

/**
 * Adds Extra Mining Time to [sessionId] (or the user's active session when
 * the app lost track of it, e.g. it was killed mid-purchase). If no session
 * is active any more the player already paid, so they get the time's value
 * as coins instead (Rs 1 ~ 2 coins, same rate as the coin packs).
 */
async function extendSession(
  // deno-lint-ignore no-explicit-any
  admin: any,
  userId: string,
  sessionId: string | undefined,
  minutes: number,
  purchaseId: string,
  priceCents: number,
): Promise<void> {
  let query = admin.from("mining_sessions").select("id, expected_end_at").eq("user_id", userId).eq("status", "active");
  if (sessionId) query = query.eq("id", sessionId);
  const { data: session } = await query.order("started_at", { ascending: false }).limit(1).maybeSingle();

  if (!session) {
    await admin.from("reward_transactions").insert({
      user_id: userId,
      type: "purchase",
      amount: Math.round((priceCents / 100) * 2),
      source: "google_play_extension_refund",
      reference_id: purchaseId,
      status: "completed",
    });
    return;
  }

  const end = new Date(session.expected_end_at);
  const base = end > new Date() ? end : new Date();
  const newEnd = new Date(base.getTime() + minutes * 60 * 1000);
  await admin
    .from("mining_sessions")
    .update({ expected_end_at: newEnd.toISOString() })
    .eq("id", session.id)
    .eq("status", "active");
  await admin.from("purchases").update({ session_id: session.id }).eq("id", purchaseId);
}

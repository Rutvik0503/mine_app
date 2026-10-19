// grant-ad-boost
// Called after AdsService confirms a rewarded ad was watched to completion
// (RewardedAd's onUserEarnedReward - see lib/core/services/ads_service.dart).
// The ad SDK's reward callback is a client-side signal we can't
// cryptographically verify, so this keeps the actual grant server-side and
// caps it: repeated calls extend an existing boost's expiry instead of
// stacking a new row, and the expiry can never exceed MAX_TOTAL_MINUTES from
// now - so spamming "watch ad" can't compound the mining multiplier or run
// the boost forever. Which boost is granted is picked at random from every
// active ad-sourced boost, so a single "watch ad" button surfaces all of
// them (2X Mining, Speed, Efficiency, Lucky Reward) instead of always the
// same one.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

const MAX_TOTAL_MINUTES = 180;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);

    const { data: adBoosts, error: boostError } = await admin
      .from("boosts")
      .select("*")
      .eq("source", "ad")
      .eq("is_active", true);
    if (boostError || !adBoosts || adBoosts.length === 0) {
      throw new Error("No ad boost is configured right now");
    }
    const boost = adBoosts[Math.floor(Math.random() * adBoosts.length)];

    const now = new Date();
    const maxExpiresAt = new Date(now.getTime() + MAX_TOTAL_MINUTES * 60 * 1000);

    const { data: existing } = await admin
      .from("user_boosts")
      .select("*")
      .eq("user_id", user.id)
      .eq("boost_id", boost.id)
      .eq("status", "active")
      .gt("expires_at", now.toISOString())
      .maybeSingle();

    if (existing) {
      const extended = new Date(new Date(existing.expires_at).getTime() + boost.duration_minutes * 60 * 1000);
      const newExpiry = extended > maxExpiresAt ? maxExpiresAt : extended;

      const { error: updateError } = await admin
        .from("user_boosts")
        .update({ expires_at: newExpiry.toISOString() })
        .eq("id", existing.id);
      if (updateError) throw updateError;

      return jsonResponse({ ok: true, boost_name: boost.name, expires_at: newExpiry.toISOString() });
    }

    const expiresAt = new Date(now.getTime() + boost.duration_minutes * 60 * 1000);

    const { error: insertError } = await admin.from("user_boosts").insert({
      user_id: user.id,
      boost_id: boost.id,
      started_at: now.toISOString(),
      expires_at: expiresAt.toISOString(),
      status: "active",
    });
    if (insertError) throw insertError;

    return jsonResponse({ ok: true, boost_name: boost.name, expires_at: expiresAt.toISOString() });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "grant-ad-boost failed", 400);
  }
});

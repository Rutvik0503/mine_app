// activate-referral (apply-referral)
// Lets a user who skipped entering a referral code at signup link one
// later. Activation/reward granting happens separately in claim-mining
// (see _shared/referral.ts) once the referred user completes a session.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const referralCode: string | undefined = body.referral_code;
    if (!referralCode) throw new Error("referral_code is required");

    const { data: profile } = await admin.from("profiles").select("referred_by").eq("id", user.id).single();
    if (profile?.referred_by) throw new Error("You already used a referral code");

    const { data: referrer } = await admin
      .from("profiles")
      .select("id")
      .eq("referral_code", referralCode.trim().toUpperCase())
      .maybeSingle();
    if (!referrer) throw new Error("Referral code not found");
    if (referrer.id === user.id) throw new Error("You cannot refer yourself");

    const { data: existing } = await admin
      .from("referrals")
      .select("id")
      .eq("referred_user_id", user.id)
      .maybeSingle();
    if (existing) throw new Error("A referral is already linked to your account");

    await admin.from("profiles").update({ referred_by: referrer.id }).eq("id", user.id);
    await admin.from("referrals").insert({
      referrer_id: referrer.id,
      referred_user_id: user.id,
      referral_code: referralCode,
      status: "pending",
    });

    return jsonResponse({ ok: true });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "activate-referral failed", 400);
  }
});

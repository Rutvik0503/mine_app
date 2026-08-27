// create-profile
// Called once, right after Supabase Auth signup. Idempotent: safe to call
// more than once for the same user. Creates the profile row, a starter farm
// and a starter machine (see docs section 8 "Authentication flow").

import { adminClient, generateReferralCode, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const referralCode: string | undefined = body.referral_code;
    const username: string | undefined = body.username;

    const { data: existing } = await admin
      .from("profiles")
      .select("id")
      .eq("id", user.id)
      .maybeSingle();

    if (existing) {
      return jsonResponse({ ok: true, already_existed: true });
    }

    let referredBy: string | null = null;
    if (referralCode) {
      const { data: referrer } = await admin
        .from("profiles")
        .select("id")
        .eq("referral_code", referralCode.trim().toUpperCase())
        .maybeSingle();
      if (referrer) referredBy = referrer.id;
    }

    const finalUsername = (username && username.trim()) || `Miner${Math.floor(1000 + Math.random() * 9000)}`;
    const newReferralCode = generateReferralCode(finalUsername);

    const { error: profileError } = await admin.from("profiles").insert({
      id: user.id,
      email: user.email ?? "",
      username: finalUsername,
      referral_code: newReferralCode,
      referred_by: referredBy,
    });
    if (profileError) throw profileError;

    if (referredBy) {
      await admin.from("referrals").insert({
        referrer_id: referredBy,
        referred_user_id: user.id,
        referral_code: referralCode,
        status: "pending",
      });
    }

    const { data: farmType } = await admin
      .from("farm_types")
      .select("id, machine_capacity, base_multiplier")
      .eq("is_active", true)
      .order("unlock_level", { ascending: true })
      .limit(1)
      .maybeSingle();

    if (!farmType) throw new Error("No farm_types configured - seed the database first");

    const { data: farm, error: farmError } = await admin
      .from("farms")
      .insert({
        user_id: user.id,
        farm_type_id: farmType.id,
        name: "My Farm",
        level: 1,
        capacity: farmType.machine_capacity,
        multiplier: farmType.base_multiplier,
      })
      .select()
      .single();
    if (farmError) throw farmError;

    const { data: starterMachine } = await admin
      .from("machines")
      .select("id, base_hashrate, base_efficiency")
      .eq("is_active", true)
      .order("base_hashrate", { ascending: true })
      .limit(1)
      .maybeSingle();

    if (starterMachine) {
      await admin.from("user_machines").insert({
        user_id: user.id,
        farm_id: farm.id,
        machine_id: starterMachine.id,
        level: 1,
        current_hashrate: starterMachine.base_hashrate,
        current_efficiency: starterMachine.base_efficiency,
      });

      await admin
        .from("profiles")
        .update({ total_hashrate: starterMachine.base_hashrate * farmType.base_multiplier })
        .eq("id", user.id);
    }

    await admin.from("streaks").insert({ user_id: user.id, current_streak: 0, longest_streak: 0 });

    return jsonResponse({ ok: true, already_existed: false });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "create-profile failed", 500);
  }
});

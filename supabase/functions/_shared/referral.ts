import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Activates a pending referral the first time the referred user completes a
 * mining claim, and grants both sides the configured non-cash referral
 * reward (docs section 26 "Referral becomes Active" / "Both receive
 * In-App Benefits"). Safe to call repeatedly - no-op once already active.
 */
export async function activateReferralIfEligible(admin: SupabaseClient, referredUserId: string): Promise<void> {
  const { data: referral } = await admin
    .from("referrals")
    .select("*")
    .eq("referred_user_id", referredUserId)
    .eq("status", "pending")
    .maybeSingle();
  if (!referral) return;

  if (referral.referrer_id === referredUserId) {
    // Anti-fraud: self-referral (docs section 27) - reject instead of activating.
    await admin.from("referrals").update({ status: "rejected" }).eq("id", referral.id);
    return;
  }

  const { data: config } = await admin.from("app_config").select("referral_reward").limit(1).maybeSingle();
  const reward = Number(config?.referral_reward ?? 50);

  await admin
    .from("referrals")
    .update({ status: "active", activated_at: new Date().toISOString() })
    .eq("id", referral.id);

  await admin.from("reward_transactions").insert([
    { user_id: referral.referrer_id, type: "referral", amount: reward, source: "referral_activated", reference_id: referral.id, status: "completed" },
    { user_id: referredUserId, type: "referral", amount: reward, source: "referral_activated", reference_id: referral.id, status: "completed" },
  ]);
}

import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendPushToUser } from "./fcm.ts";

// Referral rewards, granted the moment the friend signs up:
//  - the referrer gets a 24h Auto Mining pass (capped, see MAX_AUTO_PASSES),
//  - the new player gets a welcome bonus in coins.
const MAX_AUTO_PASSES = 7;
const WELCOME_BONUS = 50;

export async function grantReferralRewards(
  // deno-lint-ignore no-explicit-any
  admin: any,
  referrerId: string,
  newUserId: string,
  newUsername: string,
): Promise<void> {
  const { data: referrer } = await admin
    .from("profiles")
    .select("auto_mining_passes")
    .eq("id", referrerId)
    .maybeSingle();
  const passes = Number(referrer?.auto_mining_passes ?? 0);
  if (passes < MAX_AUTO_PASSES) {
    await admin.from("profiles").update({ auto_mining_passes: passes + 1 }).eq("id", referrerId);
  }

  await admin.from("reward_transactions").insert({
    user_id: newUserId,
    type: "referral",
    amount: WELCOME_BONUS,
    source: "referral_welcome",
    status: "completed",
  });

  await sendPushToUser(admin, referrerId, {
    type: "referral",
    title: {
      en: "⚡ You earned 24h Auto Mining!",
      gu: "⚡ તમને 24 કલાક Auto Mining મળ્યું!",
      hi: "⚡ आपको 24 घंटे Auto Mining मिला!",
    },
    body: {
      en: `${newUsername} joined with your code. Your next mining session runs for 24 hours.`,
      gu: `${newUsername} તમારા code થી જોડાયા. તમારું આગલું mining session 24 કલાક ચાલશે.`,
      hi: `${newUsername} आपके code से जुड़े। आपका अगला mining session 24 घंटे चलेगा।`,
    },
  });
}

/**
 * Marks a pending referral active the first time the referred user
 * completes a mining claim. Safe to call repeatedly - no-op once active.
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

  // Rewards are granted at signup (create-profile: 24h Auto Mining for the
  // referrer, welcome coins for the friend). This only marks the referral
  // active once the friend actually played, for the referral list/stats.
  await admin
    .from("referrals")
    .update({ status: "active", activated_at: new Date().toISOString() })
    .eq("id", referral.id);
}

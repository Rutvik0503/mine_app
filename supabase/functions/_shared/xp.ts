import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { sendPushToUser } from "./fcm.ts";

/** XP required to reach `level` (docs section 28: 1->0, 2->500, 3->1500, 4->3000, 5->5000...). */
export function xpForLevel(level: number): number {
  if (level <= 1) return 0;
  return Math.round(500 * Math.pow(level - 1, 1.7));
}

/** Coins for reaching `level` - makes levelling up worth something. */
export function levelUpCoins(level: number): number {
  return level * 5;
}

/**
 * Adds XP to a profile and applies any level-ups this crosses, paying
 * levelUpCoins for each new level. Returns the final { xp, level } and the
 * coins paid.
 */
export async function grantXp(
  admin: SupabaseClient,
  userId: string,
  amount: number,
): Promise<{ xp: number; level: number; levelUpCoins: number }> {
  // Compare-and-set on the old xp, so two grants at once can't both pay the
  // same level-up (or lose each other's XP).
  for (let attempt = 0; attempt < 3; attempt++) {
    const { data: profile } = await admin.from("profiles").select("xp, level").eq("id", userId).single();
    const oldXp = profile?.xp ?? 0;
    const oldLevel = profile?.level ?? 1;
    const xp = oldXp + amount;
    let level = oldLevel;
    while (xp >= xpForLevel(level + 1)) {
      level += 1;
    }

    const { data: updated } = await admin
      .from("profiles")
      .update({ xp, level })
      .eq("id", userId)
      .eq("xp", oldXp)
      .select("id");
    if (!updated || updated.length === 0) continue;

    // Ledger of individual grants (not just the running total) - the Weekly/
    // Monthly XP leaderboards need "how much in the last N days", which
    // profiles.xp alone can't answer.
    if (amount > 0) {
      await admin.from("xp_events").insert({ user_id: userId, amount });
    }

    let coins = 0;
    for (let reached = oldLevel + 1; reached <= level; reached++) {
      coins += levelUpCoins(reached);
      await admin.from("reward_transactions").insert({
        user_id: userId,
        type: "level_up",
        amount: levelUpCoins(reached),
        source: `level_up_${reached}`,
        status: "completed",
      });
    }
    if (level > oldLevel) {
      await sendPushToUser(admin, userId, {
        title: {
          en: `⭐ Level ${level} reached!`,
          gu: `⭐ Level ${level} પર પહોંચ્યા!`,
          hi: `⭐ Level ${level} पर पहुंचे!`,
        },
        body: {
          en: `You earned ${coins} coins and +${Math.min(level, 100) * 0.5}% mining power.`,
          gu: `તમને ${coins} coins અને +${Math.min(level, 100) * 0.5}% mining power મળ્યા.`,
          hi: `आपको ${coins} coins और +${Math.min(level, 100) * 0.5}% mining power मिले।`,
        },
        type: "level_up",
      });
    }

    return { xp, level, levelUpCoins: coins };
  }
  throw new Error("Could not update XP - please try again");
}

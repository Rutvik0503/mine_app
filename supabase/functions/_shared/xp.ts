import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/** XP required to reach `level` (docs section 28: 1->0, 2->500, 3->1500, 4->3000, 5->5000...). */
export function xpForLevel(level: number): number {
  if (level <= 1) return 0;
  return Math.round(500 * Math.pow(level - 1, 1.7));
}

/**
 * Adds XP to a profile and applies any level-ups this crosses, returning
 * the final { xp, level }.
 */
export async function grantXp(
  admin: SupabaseClient,
  userId: string,
  amount: number,
): Promise<{ xp: number; level: number }> {
  const { data: profile } = await admin.from("profiles").select("xp, level").eq("id", userId).single();
  let xp = (profile?.xp ?? 0) + amount;
  let level = profile?.level ?? 1;

  while (xp >= xpForLevel(level + 1)) {
    level += 1;
  }

  await admin.from("profiles").update({ xp, level }).eq("id", userId);
  return { xp, level };
}

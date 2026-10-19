import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * PostgREST filter for user_machines rows that still count towards
 * hashrate: owned machines (expires_at null) plus rentals that haven't run
 * out yet. Use with `.or(activeMachineFilter())`.
 */
export function activeMachineFilter(now = new Date()): string {
  return `expires_at.is.null,expires_at.gt.${now.toISOString()}`;
}

/**
 * Recomputes and persists profiles.total_hashrate from the user's current
 * machines, farm multiplier, level and active boosts (docs section 14).
 * Call this after anything that changes hashrate inputs (upgrades, new
 * machines, farm upgrades, boosts).
 */
export async function recomputeTotalHashrate(admin: SupabaseClient, userId: string): Promise<number> {
  const { data: profile } = await admin.from("profiles").select("level").eq("id", userId).single();
  const { data: farm } = await admin.from("farms").select("multiplier").eq("user_id", userId).single();
  const { data: machines } = await admin
    .from("user_machines")
    .select("current_hashrate")
    .eq("user_id", userId)
    .eq("status", "active")
    .or(activeMachineFilter());
  const { data: activeBoosts } = await admin
    .from("user_boosts")
    .select("boosts(multiplier, type)")
    .eq("user_id", userId)
    .eq("status", "active")
    .gt("expires_at", new Date().toISOString());

  const machineHashrate = (machines ?? []).reduce((sum, m) => sum + Number(m.current_hashrate ?? 0), 0);
  const farmMultiplier = Number(farm?.multiplier ?? 1);
  const userMultiplier = 1 + Math.min(profile?.level ?? 1, 100) * 0.005;
  const boostMultiplier = (activeBoosts ?? []).reduce((mult: number, ub: any) => {
    const boost = ub.boosts;
    if (boost?.type === "mining" || boost?.type === "efficiency" || boost?.type === "lucky") {
      return mult * Number(boost.multiplier ?? 1);
    }
    return mult;
  }, 1);

  const total = machineHashrate * farmMultiplier * userMultiplier * boostMultiplier;
  await admin.from("profiles").update({ total_hashrate: total }).eq("id", userId);
  return total;
}

/** Machine upgrade curve: base_hashrate compounding ~30%/level (docs section 19 example). */
export function hashrateForLevel(baseHashrate: number, level: number): number {
  return Math.round(baseHashrate * Math.pow(1.3, Math.max(level - 1, 0)) * 100) / 100;
}

export function upgradeCostForLevel(nextLevel: number): number {
  return Math.round(100 * Math.pow(nextLevel, 1.6));
}

export function farmUpgradeCostForLevel(nextLevel: number): number {
  return Math.round(500 * Math.pow(nextLevel, 1.7));
}

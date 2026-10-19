import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { hashrateForLevel, recomputeTotalHashrate, upgradeCostForLevel } from "./hashrate.ts";
import { bumpMissionProgress } from "./missions.ts";

/**
 * Loads one of the user's machines and works out its next upgrade. Throws
 * if it isn't theirs, is already maxed, or is a rented store miner (rentals
 * run at their listed hashrate for the plan period and can't be levelled).
 */
export async function nextMachineUpgrade(admin: SupabaseClient, userId: string, userMachineId: string) {
  const { data: userMachine, error } = await admin
    .from("user_machines")
    .select("*, machines(base_hashrate, max_level, base_efficiency)")
    .eq("id", userMachineId)
    .eq("user_id", userId)
    .single();
  if (error || !userMachine) throw new Error("Machine not found");
  if (userMachine.expires_at) throw new Error("Rented miners can't be upgraded");

  const maxLevel = userMachine.machines?.max_level ?? 10;
  if (userMachine.level >= maxLevel) throw new Error("Machine is already at maximum level");

  const nextLevel = userMachine.level + 1;
  return { userMachine, nextLevel, cost: upgradeCostForLevel(nextLevel) };
}

/**
 * Raises the machine one level and refreshes hashrate + mission progress.
 * Payment (points debit or Razorpay capture) is the caller's job.
 */
export async function applyMachineUpgrade(admin: SupabaseClient, userId: string, userMachineId: string) {
  const { userMachine, nextLevel, cost } = await nextMachineUpgrade(admin, userId, userMachineId);

  const newHashrate = hashrateForLevel(userMachine.machines?.base_hashrate ?? 1, nextLevel);
  const newEfficiency = Math.min((userMachine.machines?.base_efficiency ?? 0.8) + 0.01 * nextLevel, 0.98);

  const { error: updateError } = await admin
    .from("user_machines")
    .update({
      level: nextLevel,
      current_hashrate: newHashrate,
      current_efficiency: newEfficiency,
      updated_at: new Date().toISOString(),
    })
    .eq("id", userMachine.id);
  if (updateError) throw updateError;

  const totalHashrate = await recomputeTotalHashrate(admin, userId);
  await bumpMissionProgress(admin, userId, "upgrade_machine");

  return { level: nextLevel, hashrate: newHashrate, efficiency: newEfficiency, cost, totalHashrate };
}

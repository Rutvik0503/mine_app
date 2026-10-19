import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { activeMachineFilter, recomputeTotalHashrate } from "./hashrate.ts";

/** Number of machines currently occupying a farm slot. */
export async function activeMachineCount(admin: SupabaseClient, userId: string): Promise<number> {
  const { count } = await admin
    .from("user_machines")
    .select("id", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("status", "active")
    .or(activeMachineFilter());
  return count ?? 0;
}

/**
 * Throws unless the user can take on [machineId] right now: either they
 * already rent it (renewing extends it, no new slot) or the farm has a free
 * slot. Called before charging - never after a payment has been captured.
 */
export async function assertCanRent(admin: SupabaseClient, userId: string, machineId: string): Promise<void> {
  const { data: farm } = await admin.from("farms").select("capacity").eq("user_id", userId).single();
  if (!farm) throw new Error("Farm not found");

  const { data: existing } = await admin
    .from("user_machines")
    .select("id")
    .eq("user_id", userId)
    .eq("machine_id", machineId)
    .eq("status", "active")
    .gt("expires_at", new Date().toISOString())
    .limit(1)
    .maybeSingle();
  if (existing) return;

  const used = await activeMachineCount(admin, userId);
  if (used >= farm.capacity) {
    throw new Error("Your farm is full - upgrade the farm to add more machines");
  }
}

/**
 * Grants a plan's rental: extends an active rental of the same machine, or
 * adds the machine to the user's farm until now + duration. Doesn't check
 * capacity (see assertCanRent) since by the time this runs the user may
 * already have paid.
 */
export async function grantMachineRental(
  admin: SupabaseClient,
  userId: string,
  planId: string,
): Promise<{ userMachineId: string; expiresAt: string }> {
  const { data: plan, error: planError } = await admin
    .from("machine_plans")
    .select("id, duration_days, machine_id, machines(base_hashrate, base_efficiency)")
    .eq("id", planId)
    .single();
  if (planError || !plan) throw new Error("Plan not found");

  const durationMs = plan.duration_days * 24 * 60 * 60 * 1000;
  const now = new Date();

  const { data: existing } = await admin
    .from("user_machines")
    .select("id, expires_at")
    .eq("user_id", userId)
    .eq("machine_id", plan.machine_id)
    .eq("status", "active")
    .gt("expires_at", now.toISOString())
    .order("expires_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  let userMachineId: string;
  let expiresAt: Date;

  if (existing) {
    expiresAt = new Date(new Date(existing.expires_at).getTime() + durationMs);
    const { error } = await admin
      .from("user_machines")
      .update({ expires_at: expiresAt.toISOString(), plan_id: plan.id, updated_at: now.toISOString() })
      .eq("id", existing.id);
    if (error) throw error;
    userMachineId = existing.id;
  } else {
    const { data: farm } = await admin.from("farms").select("id").eq("user_id", userId).single();
    if (!farm) throw new Error("Farm not found");
    const machine = (plan as any).machines;
    expiresAt = new Date(now.getTime() + durationMs);
    const { data: inserted, error } = await admin
      .from("user_machines")
      .insert({
        user_id: userId,
        farm_id: farm.id,
        machine_id: plan.machine_id,
        level: 1,
        current_hashrate: Number(machine?.base_hashrate ?? 0),
        current_efficiency: Number(machine?.base_efficiency ?? 0.8),
        status: "active",
        expires_at: expiresAt.toISOString(),
        plan_id: plan.id,
      })
      .select("id")
      .single();
    if (error) throw error;
    userMachineId = inserted.id;
  }

  await recomputeTotalHashrate(admin, userId);
  return { userMachineId, expiresAt: expiresAt.toISOString() };
}

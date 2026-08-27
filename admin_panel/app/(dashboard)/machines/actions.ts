"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function addMachine(formData: FormData) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const row = {
    name: String(formData.get("name")),
    machine_type: String(formData.get("machine_type") || "standard"),
    base_hashrate: Number(formData.get("base_hashrate")),
    base_efficiency: Number(formData.get("base_efficiency")),
    max_level: Number(formData.get("max_level")),
    is_active: true,
  };

  const { data, error } = await client.from("machines").insert(row).select().single();
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: "add_machine",
    target_type: "machines",
    target_id: data.id,
    new_value: row,
  });

  revalidatePath("/machines");
}

export async function toggleMachineActive(machineId: string, nextActive: boolean) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const { error } = await client.from("machines").update({ is_active: nextActive }).eq("id", machineId);
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: nextActive ? "enable_machine" : "disable_machine",
    target_type: "machines",
    target_id: machineId,
  });

  revalidatePath("/machines");
}

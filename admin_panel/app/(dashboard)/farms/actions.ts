"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function addFarmType(formData: FormData) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const row = {
    name: String(formData.get("name")),
    description: String(formData.get("description") || ""),
    base_multiplier: Number(formData.get("base_multiplier")),
    machine_capacity: Number(formData.get("machine_capacity")),
    unlock_level: Number(formData.get("unlock_level")),
    is_active: true,
  };

  const { data, error } = await client.from("farm_types").insert(row).select().single();
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: "add_farm_type",
    target_type: "farm_types",
    target_id: data.id,
    new_value: row,
  });

  revalidatePath("/farms");
}

export async function toggleFarmTypeActive(farmTypeId: string, nextActive: boolean) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const { error } = await client.from("farm_types").update({ is_active: nextActive }).eq("id", farmTypeId);
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: nextActive ? "enable_farm_type" : "disable_farm_type",
    target_type: "farm_types",
    target_id: farmTypeId,
  });

  revalidatePath("/farms");
}

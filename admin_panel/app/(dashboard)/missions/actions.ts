"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function addMission(formData: FormData) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const row = {
    title: String(formData.get("title")),
    description: String(formData.get("description") || ""),
    type: String(formData.get("type")),
    target: Number(formData.get("target")),
    reward_xp: Number(formData.get("reward_xp")),
    reward_points: Number(formData.get("reward_points")),
    is_active: true,
  };

  const { data, error } = await client.from("missions").insert(row).select().single();
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: "add_mission",
    target_type: "missions",
    target_id: data.id,
    new_value: row,
  });

  revalidatePath("/missions");
}

export async function toggleMissionActive(missionId: string, nextActive: boolean) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const { error } = await client.from("missions").update({ is_active: nextActive }).eq("id", missionId);
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: nextActive ? "enable_mission" : "disable_mission",
    target_type: "missions",
    target_id: missionId,
  });

  revalidatePath("/missions");
}

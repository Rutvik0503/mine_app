"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function updateMiningSettings(formData: FormData) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const { data: config } = await client.from("app_config").select("id").limit(1).maybeSingle();
  if (!config) throw new Error("app_config row not found - re-run the SQL seed migration");

  const newValue = {
    mining_rate: Number(formData.get("mining_rate")),
    max_session_minutes: Number(formData.get("max_session_minutes")),
    default_boost: Number(formData.get("default_boost")),
    referral_reward: Number(formData.get("referral_reward")),
    maintenance_mode: formData.get("maintenance_mode") === "on",
    minimum_app_version: String(formData.get("minimum_app_version")),
    updated_at: new Date().toISOString(),
  };

  const { error } = await client.from("app_config").update(newValue).eq("id", config.id);
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: "update_mining_settings",
    target_type: "app_config",
    target_id: config.id,
    new_value: newValue,
  });

  revalidatePath("/mining-settings");
}

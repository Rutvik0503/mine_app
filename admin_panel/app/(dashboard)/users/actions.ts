"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

async function setUserStatus(userId: string, status: "active" | "blocked" | "flagged") {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const { data: before } = await client.from("profiles").select("status").eq("id", userId).single();

  const { error } = await client.from("profiles").update({ status }).eq("id", userId);
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: `set_status_${status}`,
    target_type: "profiles",
    target_id: userId,
    old_value: before,
    new_value: { status },
  });

  revalidatePath("/users");
}

export async function blockUser(userId: string) {
  await setUserStatus(userId, "blocked");
}

export async function unblockUser(userId: string) {
  await setUserStatus(userId, "active");
}

export async function flagUser(userId: string) {
  await setUserStatus(userId, "flagged");
}

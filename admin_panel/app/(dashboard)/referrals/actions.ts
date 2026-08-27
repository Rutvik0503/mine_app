"use server";

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

export async function rejectReferral(referralId: string) {
  const admin = await requireAdmin();
  const client = createSupabaseAdminClient();

  const { error } = await client.from("referrals").update({ status: "rejected" }).eq("id", referralId);
  if (error) throw new Error(error.message);

  await client.from("admin_audit_logs").insert({
    admin_id: admin.userId,
    action: "reject_referral",
    target_type: "referrals",
    target_id: referralId,
  });

  revalidatePath("/referrals");
}

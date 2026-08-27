import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "./supabase/server";

export type AdminSession = {
  userId: string;
  email: string;
  role: "admin" | "superadmin";
};

/**
 * Confirms the visitor is signed in AND present in admin_users (see
 * supabase/migrations/0002_admin.sql). Redirects to /login otherwise.
 * Call this at the top of every protected Server Component/page.
 */
export async function requireAdmin(): Promise<AdminSession> {
  const supabase = await createSupabaseServerClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: adminRow } = await supabase
    .from("admin_users")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();

  if (!adminRow) redirect("/login?error=not_admin");

  return { userId: user.id, email: user.email ?? "", role: adminRow.role };
}

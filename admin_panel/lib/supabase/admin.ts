import { createClient } from "@supabase/supabase-js";

/**
 * Privileged client using the service_role key - bypasses RLS entirely.
 * Import this ONLY in Server Components, Server Actions or Route Handlers,
 * and only after requireAdmin() has confirmed the caller is an admin.
 * Never import this file from a "use client" component.
 */
export function createSupabaseAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL!;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceRoleKey) {
    throw new Error(
      "SUPABASE_SERVICE_ROLE_KEY is not set. Copy .env.local.example to .env.local and fill it in.",
    );
  }
  return createClient(url, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

import { createClient, SupabaseClient, User } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Admin client - uses the service_role key, bypasses RLS entirely.
 * Only ever used server-side inside Edge Functions, never shipped to Flutter.
 */
export function adminClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  return createClient(url, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

/**
 * Resolves the calling user from the request's Authorization header
 * (the Flutter app always sends the user's own JWT via supabase-flutter's
 * functions.invoke, which forwards the current session automatically).
 */
export async function getRequestUser(
  req: Request,
  client: SupabaseClient,
): Promise<User> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace("Bearer ", "");
  if (!token) throw new Error("Missing Authorization header");

  const { data, error } = await client.auth.getUser(token);
  if (error || !data.user) throw new Error("Invalid or expired session");
  return data.user;
}

export function generateReferralCode(username: string): string {
  const suffix = Math.floor(1000 + Math.random() * 9000);
  const base = username.replace(/[^a-zA-Z0-9]/g, "").toUpperCase().slice(0, 6) || "MINER";
  return `${base}${suffix}`;
}

// get-dashboard
// Optional aggregate endpoint - the Flutter app currently reads these same
// tables directly (RLS-protected), but this is handy for a future admin
// panel widget or to cut round-trips once the app grows.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);

    const [profile, farm, session, streak, txns] = await Promise.all([
      admin.from("profiles").select("*").eq("id", user.id).single(),
      admin.from("farms").select("*, farm_types(*)").eq("user_id", user.id).maybeSingle(),
      admin.from("mining_sessions").select("*").eq("user_id", user.id).eq("status", "active").maybeSingle(),
      admin.from("streaks").select("*").eq("user_id", user.id).maybeSingle(),
      admin.from("reward_transactions").select("amount, status").eq("user_id", user.id),
    ]);

    const availableBalance = (txns.data ?? [])
      .filter((t) => t.status === "completed")
      .reduce((sum, t) => sum + Number(t.amount ?? 0), 0);
    const pendingBalance = (txns.data ?? [])
      .filter((t) => t.status === "pending")
      .reduce((sum, t) => sum + Number(t.amount ?? 0), 0);

    return jsonResponse({
      profile: profile.data,
      farm: farm.data,
      active_session: session.data,
      streak: streak.data,
      available_balance: availableBalance,
      pending_balance: pendingBalance,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "get-dashboard failed", 400);
  }
});

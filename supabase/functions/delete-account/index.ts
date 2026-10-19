// delete-account
// Permanently deletes the calling user's account (Google Play's account
// deletion requirement). Removing the auth user cascades to profiles and
// every per-user table (farms, machines, sessions, rewards, purchases, ...).

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);

    // profiles.referred_by has no ON DELETE action, so clear it on anyone
    // this user referred first - otherwise the cascade fails.
    const { error: unlinkError } = await admin
      .from("profiles")
      .update({ referred_by: null })
      .eq("referred_by", user.id);
    if (unlinkError) throw unlinkError;

    const { error: deleteError } = await admin.auth.admin.deleteUser(user.id);
    if (deleteError) throw deleteError;

    return jsonResponse({ ok: true });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "delete-account failed", 400);
  }
});

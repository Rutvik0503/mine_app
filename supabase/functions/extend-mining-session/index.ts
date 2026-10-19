// extend-mining-session
// Free, ad-gated extension of the current mining session's expected_end_at
// once it's ready to claim - called after AdsService confirms the rewarded
// ad was watched to completion (same trust boundary as grant-ad-boost).
// Capped at MAX_AD_EXTENSIONS per session so repeated ad-watching can't
// stretch a session (and its eventual reward, which scales with duration)
// without bound.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

const EXTENSION_MINUTES = 15;
const MAX_AD_EXTENSIONS = 2;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const sessionId: string | undefined = body.session_id;
    if (!sessionId) throw new Error("session_id is required");

    const { data: session, error: sessionError } = await admin
      .from("mining_sessions")
      .select("*")
      .eq("id", sessionId)
      .eq("user_id", user.id)
      .single();
    if (sessionError || !session) throw new Error("Mining session not found");

    if (session.status !== "active") throw new Error("This session has already ended");
    if (new Date(session.expected_end_at) > new Date()) {
      throw new Error("Session is still in progress");
    }
    if (session.ad_extensions_used >= MAX_AD_EXTENSIONS) {
      throw new Error("No more free extensions available for this session");
    }

    const newEndAt = new Date(new Date(session.expected_end_at).getTime() + EXTENSION_MINUTES * 60 * 1000);

    const { data: updated, error: updateError } = await admin
      .from("mining_sessions")
      .update({
        expected_end_at: newEndAt.toISOString(),
        ad_extensions_used: session.ad_extensions_used + 1,
      })
      .eq("id", session.id)
      .eq("status", "active")
      .eq("ad_extensions_used", session.ad_extensions_used) // guards a race with another extend/claim
      .select("*")
      .single();
    if (updateError || !updated) throw new Error("Could not extend session - try again");

    return jsonResponse({ ok: true, session: updated });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "extend-mining-session failed", 400);
  }
});

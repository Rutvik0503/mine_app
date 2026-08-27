// request-withdrawal (FUTURE PHASE - see docs section 35-36)
//
// V1 has no real crypto/cash withdrawal. This stub exists so the schema and
// API surface match the documented future architecture, and so the admin
// panel/wallet UI has something to point at once withdrawals are enabled.
// Do NOT wire a "Withdraw" button to this until:
//   1. Legal/compliance sign-off for real-money payouts in your region.
//   2. A real blockchain/payment integration replaces the stub below.
//   3. Google Play policy review for the changed monetization model.

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    await getRequestUser(req, admin); // still require a valid session even though this is a stub

    return errorResponse("Withdrawals are not available yet.", 501);
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "request-withdrawal failed", 400);
  }
});

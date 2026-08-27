// complete-mission (claim-mission-reward)
// Grants XP + points for a completed mission, once (idempotent).

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { grantXp } from "../_shared/xp.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    const userMissionId: string | undefined = body.user_mission_id;
    if (!userMissionId) throw new Error("user_mission_id is required");

    const { data: userMission, error: umError } = await admin
      .from("user_missions")
      .select("*, missions(reward_xp, reward_points, title)")
      .eq("id", userMissionId)
      .eq("user_id", user.id)
      .single();
    if (umError || !userMission) throw new Error("Mission not found");

    if (userMission.status === "claimed") throw new Error("This reward has already been claimed");
    if (userMission.status !== "completed") throw new Error("Mission is not completed yet");

    const rewardXp = Number(userMission.missions?.reward_xp ?? 0);
    const rewardPoints = Number(userMission.missions?.reward_points ?? 0);

    const { error: updateError } = await admin
      .from("user_missions")
      .update({ status: "claimed" })
      .eq("id", userMission.id)
      .eq("status", "completed"); // guard against a race with another claim
    if (updateError) throw updateError;

    if (rewardPoints > 0) {
      await admin.from("reward_transactions").insert({
        user_id: user.id,
        type: "mission",
        amount: rewardPoints,
        source: userMission.missions?.title ?? "mission",
        reference_id: userMission.id,
        status: "completed",
      });
    }

    const { xp, level } = await grantXp(admin, user.id, rewardXp);

    return jsonResponse({ ok: true, reward_xp: rewardXp, reward_points: rewardPoints, xp, level });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "complete-mission failed", 400);
  }
});

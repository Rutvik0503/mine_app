import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Increments progress on today's user_missions rows whose mission `type`
 * matches, marking them `completed` once target is reached. Called as a
 * side effect from start-mining / claim-mining / upgrade-machine.
 */
export async function bumpMissionProgress(
  admin: SupabaseClient,
  userId: string,
  missionType: "start_mining" | "claim_mining" | "upgrade_machine",
  amount = 1,
): Promise<void> {
  const today = new Date().toISOString().slice(0, 10);

  const { data: rows } = await admin
    .from("user_missions")
    .select("id, progress, target, status, missions!inner(type)")
    .eq("user_id", userId)
    .eq("date", today)
    .eq("status", "in_progress")
    .eq("missions.type", missionType);

  for (const row of rows ?? []) {
    const newProgress = Math.min(row.progress + amount, row.target);
    const completed = newProgress >= row.target;
    await admin
      .from("user_missions")
      .update({
        progress: newProgress,
        status: completed ? "completed" : "in_progress",
        completed_at: completed ? new Date().toISOString() : null,
      })
      .eq("id", row.id);
  }
}

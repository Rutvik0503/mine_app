// update-streak
// Server decides whether today already counted, whether the streak
// continues or resets, and grants the day's XP bonus (docs section 20).

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { grantXp } from "../_shared/xp.ts";

const DAILY_XP = [100, 120, 150, 180, 220, 250, 300]; // day 1..7 of the cycle, day 7 = special bonus

function todayUtc(): string {
  return new Date().toISOString().slice(0, 10);
}

function daysBetween(a: string, b: string): number {
  const msPerDay = 1000 * 60 * 60 * 24;
  return Math.round((new Date(b).getTime() - new Date(a).getTime()) / msPerDay);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const today = todayUtc();

    const { data: streak } = await admin.from("streaks").select("*").eq("user_id", user.id).single();
    if (!streak) throw new Error("Streak record not found");

    if (streak.last_completed_date === today) {
      return jsonResponse({ ok: true, already_checked_in: true, current_streak: streak.current_streak });
    }

    let newStreak = 1;
    if (streak.last_completed_date) {
      const gap = daysBetween(streak.last_completed_date, today);
      newStreak = gap === 1 ? streak.current_streak + 1 : 1;
    }
    const newLongest = Math.max(streak.longest_streak, newStreak);

    const { error: updateError } = await admin
      .from("streaks")
      .update({
        current_streak: newStreak,
        longest_streak: newLongest,
        last_completed_date: today,
        updated_at: new Date().toISOString(),
      })
      .eq("id", streak.id);
    if (updateError) throw updateError;

    await admin.from("profiles").update({ streak_days: newStreak, last_active_at: new Date().toISOString() }).eq("id", user.id);

    const dayInCycle = ((newStreak - 1) % 7) + 1;
    const xpReward = DAILY_XP[dayInCycle - 1];
    const { xp, level } = await grantXp(admin, user.id, xpReward);

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "streak",
      amount: 0,
      source: `streak_day_${newStreak}`,
      status: "completed",
    });

    return jsonResponse({
      ok: true,
      already_checked_in: false,
      current_streak: newStreak,
      longest_streak: newLongest,
      xp_awarded: xpReward,
      xp,
      level,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "update-streak failed", 400);
  }
});

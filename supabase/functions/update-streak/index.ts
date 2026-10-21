// update-streak
// Server decides whether today already counted, whether the streak
// continues or resets, and grants the day's XP + coin bonus (docs section 20).

import { adminClient, getRequestUser } from "../_shared/client.ts";
import { corsHeaders, errorResponse, jsonResponse } from "../_shared/cors.ts";
import { grantXp } from "../_shared/xp.ts";

const DAILY_XP = [100, 120, 150, 180, 220, 250, 300]; // day 1..7 of the cycle, day 7 = special bonus
const DAILY_COINS = [1, 1, 2, 2, 3, 3, 5];

function todayUtc(): string {
  return new Date().toISOString().slice(0, 10);
}

function daysBetween(a: string, b: string): number {
  const msPerDay = 1000 * 60 * 60 * 24;
  return Math.round((new Date(b).getTime() - new Date(a).getTime()) / msPerDay);
}

function playerToday(localDate: unknown): string {
  const utc = todayUtc();
  if (typeof localDate !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(localDate)) return utc;
  return Math.abs(daysBetween(utc, localDate)) <= 1 ? localDate : utc;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const admin = adminClient();
    const user = await getRequestUser(req, admin);
    const body = await req.json().catch(() => ({}));
    // The player's own calendar date, so the streak day ends at *their*
    // midnight (UTC would end it at 5:30 AM in India). Only trusted within a
    // day of UTC - no time zone is further off than that.
    const today = playerToday(body.local_date);

    const { data: streak } = await admin.from("streaks").select("*").eq("user_id", user.id).single();
    if (!streak) throw new Error("Streak record not found");

    // "<=" also covers moving west across time zones (local date behind
    // the last check-in): that's still the same day, not a broken streak.
    if (streak.last_completed_date && streak.last_completed_date >= today) {
      return jsonResponse({ ok: true, already_checked_in: true, current_streak: streak.current_streak });
    }

    let newStreak = 1;
    if (streak.last_completed_date) {
      const gap = daysBetween(streak.last_completed_date, today);
      newStreak = gap === 1 ? streak.current_streak + 1 : 1;
    }
    const newLongest = Math.max(streak.longest_streak, newStreak);

    // Optimistic concurrency: only apply if last_completed_date still matches
    // what we just read. If a concurrent request already checked in today,
    // this matches zero rows and we stop before granting XP twice.
    let updateQuery = admin
      .from("streaks")
      .update({
        current_streak: newStreak,
        longest_streak: newLongest,
        last_completed_date: today,
        updated_at: new Date().toISOString(),
      })
      .eq("id", streak.id);
    updateQuery = streak.last_completed_date
      ? updateQuery.eq("last_completed_date", streak.last_completed_date)
      : updateQuery.is("last_completed_date", null);

    const { data: updated, error: updateError } = await updateQuery.select("id");
    if (updateError) throw updateError;
    if (!updated || updated.length === 0) {
      return jsonResponse({ ok: true, already_checked_in: true, current_streak: streak.current_streak });
    }

    await admin.from("profiles").update({ streak_days: newStreak, last_active_at: new Date().toISOString() }).eq("id", user.id);

    const dayInCycle = ((newStreak - 1) % 7) + 1;
    const xpReward = DAILY_XP[dayInCycle - 1];
    const coinReward = DAILY_COINS[dayInCycle - 1];
    const { xp, level, levelUpCoins } = await grantXp(admin, user.id, xpReward);

    await admin.from("reward_transactions").insert({
      user_id: user.id,
      type: "streak",
      amount: coinReward,
      source: `streak_day_${newStreak}`,
      status: "completed",
    });

    return jsonResponse({
      ok: true,
      already_checked_in: false,
      current_streak: newStreak,
      longest_streak: newLongest,
      xp_awarded: xpReward,
      coins_awarded: coinReward,
      level_up_coins: levelUpCoins,
      xp,
      level,
    });
  } catch (e) {
    return errorResponse(e instanceof Error ? e.message : "update-streak failed", 400);
  }
});

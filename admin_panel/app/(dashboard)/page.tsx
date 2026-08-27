import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";

function StatCard({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="panel p-5">
      <div className="text-xs text-[#a0a7c0] mb-2">{label}</div>
      <div className="text-2xl font-bold">{value}</div>
    </div>
  );
}

export default async function DashboardPage() {
  await requireAdmin();
  const admin = createSupabaseAdminClient();

  const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const monthAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

  const [
    totalUsers,
    dau,
    wau,
    mau,
    totalSessions,
    completedSessions,
    rewardTxns,
    activeReferrals,
    fraudFlags,
  ] = await Promise.all([
    admin.from("profiles").select("id", { count: "exact", head: true }),
    admin.from("profiles").select("id", { count: "exact", head: true }).gte("last_active_at", dayAgo),
    admin.from("profiles").select("id", { count: "exact", head: true }).gte("last_active_at", weekAgo),
    admin.from("profiles").select("id", { count: "exact", head: true }).gte("last_active_at", monthAgo),
    admin.from("mining_sessions").select("id", { count: "exact", head: true }),
    admin.from("mining_sessions").select("id", { count: "exact", head: true }).eq("status", "completed"),
    admin.from("reward_transactions").select("amount").eq("status", "completed"),
    admin.from("referrals").select("id", { count: "exact", head: true }).eq("status", "active"),
    admin.from("profiles").select("id", { count: "exact", head: true }).eq("status", "flagged"),
  ]);

  const totalRewards = (rewardTxns.data ?? []).reduce((sum, t) => sum + Number(t.amount ?? 0), 0);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Dashboard</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">Live overview of Virtual Mining Empire.</p>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total Users" value={totalUsers.count ?? 0} />
        <StatCard label="DAU" value={dau.count ?? 0} />
        <StatCard label="WAU" value={wau.count ?? 0} />
        <StatCard label="MAU" value={mau.count ?? 0} />
        <StatCard label="Mining Sessions" value={totalSessions.count ?? 0} />
        <StatCard label="Completed Sessions" value={completedSessions.count ?? 0} />
        <StatCard label="Total Rewards Paid" value={totalRewards.toFixed(0)} />
        <StatCard label="Active Referrals" value={activeReferrals.count ?? 0} />
      </div>

      {(fraudFlags.count ?? 0) > 0 && (
        <div className="panel p-4 border-[#FF5C6C]">
          <span className="text-[#FF5C6C] font-semibold">{fraudFlags.count} flagged user(s)</span>{" "}
          need review - see the Users page.
        </div>
      )}
    </div>
  );
}

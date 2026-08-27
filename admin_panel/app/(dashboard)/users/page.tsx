import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { blockUser, flagUser, unblockUser } from "./actions";

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  await requireAdmin();
  const { q } = await searchParams;
  const admin = createSupabaseAdminClient();

  let query = admin
    .from("profiles")
    .select("id, username, email, level, total_hashrate, streak_days, status, created_at")
    .order("created_at", { ascending: false })
    .limit(100);

  if (q) query = query.ilike("username", `%${q}%`);

  const { data: users } = await query;

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Users</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">Search, review and moderate player accounts.</p>

      <form className="mb-4">
        <input
          className="input w-72"
          type="text"
          name="q"
          placeholder="Search by username..."
          defaultValue={q ?? ""}
        />
      </form>

      <div className="panel overflow-x-auto">
        <table className="data-table">
          <thead>
            <tr>
              <th>Username</th>
              <th>Email</th>
              <th>Level</th>
              <th>Hashrate</th>
              <th>Streak</th>
              <th>Status</th>
              <th>Joined</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {(users ?? []).map((u) => (
              <tr key={u.id}>
                <td>{u.username}</td>
                <td className="text-[#a0a7c0]">{u.email}</td>
                <td>{u.level}</td>
                <td>{Number(u.total_hashrate).toFixed(1)} TH/s</td>
                <td>{u.streak_days}d</td>
                <td>
                  <span
                    className={
                      u.status === "active"
                        ? "text-[#3DDC97]"
                        : u.status === "blocked"
                          ? "text-[#FF5C6C]"
                          : "text-[#FFC145]"
                    }
                  >
                    {u.status}
                  </span>
                </td>
                <td className="text-[#a0a7c0]">{new Date(u.created_at).toLocaleDateString()}</td>
                <td>
                  <div className="flex gap-2">
                    {u.status !== "blocked" ? (
                      <form action={blockUser.bind(null, u.id)}>
                        <button className="btn btn-danger" type="submit">
                          Block
                        </button>
                      </form>
                    ) : (
                      <form action={unblockUser.bind(null, u.id)}>
                        <button className="btn" type="submit">
                          Unblock
                        </button>
                      </form>
                    )}
                    {u.status !== "flagged" && (
                      <form action={flagUser.bind(null, u.id)}>
                        <button className="btn btn-outline" type="submit">
                          Flag
                        </button>
                      </form>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

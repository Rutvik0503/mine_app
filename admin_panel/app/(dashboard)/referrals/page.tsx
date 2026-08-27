import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { rejectReferral } from "./actions";

export default async function ReferralsPage() {
  await requireAdmin();
  const admin = createSupabaseAdminClient();

  const { data: referrals } = await admin
    .from("referrals")
    .select(
      "id, status, referral_code, created_at, activated_at, referrer:referrer_id(username), referred:referred_user_id(username)",
    )
    .order("created_at", { ascending: false })
    .limit(200);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Referrals</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">
        Referrals activate automatically once the referred user completes their first mining
        claim. Reject any that look like self-referral or farming abuse.
      </p>

      <div className="panel overflow-x-auto">
        <table className="data-table">
          <thead>
            <tr>
              <th>Referrer</th>
              <th>Referred User</th>
              <th>Code</th>
              <th>Status</th>
              <th>Created</th>
              <th>Activated</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {(referrals ?? []).map((r: any) => (
              <tr key={r.id}>
                <td>{r.referrer?.username ?? "-"}</td>
                <td>{r.referred?.username ?? "-"}</td>
                <td className="text-[#a0a7c0]">{r.referral_code}</td>
                <td
                  className={
                    r.status === "active"
                      ? "text-[#3DDC97]"
                      : r.status === "rejected"
                        ? "text-[#FF5C6C]"
                        : "text-[#FFC145]"
                  }
                >
                  {r.status}
                </td>
                <td className="text-[#a0a7c0]">{new Date(r.created_at).toLocaleDateString()}</td>
                <td className="text-[#a0a7c0]">
                  {r.activated_at ? new Date(r.activated_at).toLocaleDateString() : "-"}
                </td>
                <td>
                  {r.status !== "rejected" && (
                    <form action={rejectReferral.bind(null, r.id)}>
                      <button className="btn btn-danger" type="submit">
                        Reject
                      </button>
                    </form>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

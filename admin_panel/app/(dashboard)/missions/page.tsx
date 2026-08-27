import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { addMission, toggleMissionActive } from "./actions";

const TYPES = ["start_mining", "claim_mining", "upgrade_machine", "custom"];

export default async function MissionsPage() {
  await requireAdmin();
  const admin = createSupabaseAdminClient();
  const { data: missions } = await admin.from("missions").select("*").order("created_at", { ascending: false });

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Missions</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">
        Active missions are assigned to every user daily. Type must match what the app tracks
        automatically (start_mining, claim_mining, upgrade_machine) or &quot;custom&quot; for
        manual/engagement missions.
      </p>

      <div className="panel overflow-x-auto mb-8">
        <table className="data-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Type</th>
              <th>Target</th>
              <th>Reward XP</th>
              <th>Reward Points</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {(missions ?? []).map((m) => (
              <tr key={m.id}>
                <td>{m.title}</td>
                <td className="text-[#a0a7c0]">{m.type}</td>
                <td>{m.target}</td>
                <td>{m.reward_xp}</td>
                <td>{m.reward_points}</td>
                <td className={m.is_active ? "text-[#3DDC97]" : "text-[#FF5C6C]"}>
                  {m.is_active ? "active" : "disabled"}
                </td>
                <td>
                  <form action={toggleMissionActive.bind(null, m.id, !m.is_active)}>
                    <button className="btn btn-outline" type="submit">
                      {m.is_active ? "Disable" : "Enable"}
                    </button>
                  </form>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="panel p-6 max-w-lg">
        <h2 className="font-semibold mb-4">Add Mission</h2>
        <form action={addMission} className="space-y-3">
          <input className="input w-full" name="title" placeholder="Title" required />
          <input className="input w-full" name="description" placeholder="Description" />
          <select className="input w-full" name="type" defaultValue="custom">
            {TYPES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
          <input className="input w-full" name="target" type="number" placeholder="Target" defaultValue={1} />
          <input
            className="input w-full"
            name="reward_xp"
            type="number"
            placeholder="Reward XP"
            defaultValue={100}
          />
          <input
            className="input w-full"
            name="reward_points"
            type="number"
            step="0.01"
            placeholder="Reward Points"
            defaultValue={0}
          />
          <button className="btn" type="submit">
            Add Mission
          </button>
        </form>
      </div>
    </div>
  );
}

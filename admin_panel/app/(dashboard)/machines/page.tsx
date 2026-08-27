import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { addMachine, toggleMachineActive } from "./actions";

export default async function MachinesPage() {
  await requireAdmin();
  const admin = createSupabaseAdminClient();
  const { data: machines } = await admin.from("machines").select("*").order("base_hashrate");

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Machines</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">
        Upgrade levels are computed automatically (~30%/level) from the base hashrate below.
      </p>

      <div className="panel overflow-x-auto mb-8">
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Type</th>
              <th>Base Hashrate</th>
              <th>Base Efficiency</th>
              <th>Max Level</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {(machines ?? []).map((m) => (
              <tr key={m.id}>
                <td>{m.name}</td>
                <td className="text-[#a0a7c0]">{m.machine_type}</td>
                <td>{m.base_hashrate} TH/s</td>
                <td>{(m.base_efficiency * 100).toFixed(0)}%</td>
                <td>{m.max_level}</td>
                <td className={m.is_active ? "text-[#3DDC97]" : "text-[#FF5C6C]"}>
                  {m.is_active ? "active" : "disabled"}
                </td>
                <td>
                  <form action={toggleMachineActive.bind(null, m.id, !m.is_active)}>
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
        <h2 className="font-semibold mb-4">Add Machine</h2>
        <form action={addMachine} className="space-y-3">
          <input className="input w-full" name="name" placeholder="Name (e.g. Miner X5)" required />
          <input className="input w-full" name="machine_type" placeholder="Type (e.g. standard, advanced)" />
          <input
            className="input w-full"
            name="base_hashrate"
            type="number"
            step="0.01"
            placeholder="Base Hashrate (TH/s)"
            required
          />
          <input
            className="input w-full"
            name="base_efficiency"
            type="number"
            step="0.01"
            placeholder="Base Efficiency (0-1)"
            defaultValue={0.8}
          />
          <input
            className="input w-full"
            name="max_level"
            type="number"
            placeholder="Max Level"
            defaultValue={10}
          />
          <button className="btn" type="submit">
            Add Machine
          </button>
        </form>
      </div>
    </div>
  );
}

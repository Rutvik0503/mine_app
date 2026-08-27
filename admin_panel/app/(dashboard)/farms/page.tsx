import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { addFarmType, toggleFarmTypeActive } from "./actions";

export default async function FarmsPage() {
  await requireAdmin();
  const admin = createSupabaseAdminClient();
  const { data: farmTypes } = await admin.from("farm_types").select("*").order("unlock_level");

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Farm Types</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">
        Existing user farms upgrade their own level/multiplier over time; these rows define what a
        farm type unlocks and starts with.
      </p>

      <div className="panel overflow-x-auto mb-8">
        <table className="data-table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Base Multiplier</th>
              <th>Machine Capacity</th>
              <th>Unlock Level</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {(farmTypes ?? []).map((f) => (
              <tr key={f.id}>
                <td>{f.name}</td>
                <td>x{f.base_multiplier}</td>
                <td>{f.machine_capacity}</td>
                <td>{f.unlock_level}</td>
                <td className={f.is_active ? "text-[#3DDC97]" : "text-[#FF5C6C]"}>
                  {f.is_active ? "active" : "disabled"}
                </td>
                <td>
                  <form action={toggleFarmTypeActive.bind(null, f.id, !f.is_active)}>
                    <button className="btn btn-outline" type="submit">
                      {f.is_active ? "Disable" : "Enable"}
                    </button>
                  </form>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="panel p-6 max-w-lg">
        <h2 className="font-semibold mb-4">Add Farm Type</h2>
        <form action={addFarmType} className="space-y-3">
          <input className="input w-full" name="name" placeholder="Name (e.g. Hydro Farm)" required />
          <input className="input w-full" name="description" placeholder="Description" />
          <input
            className="input w-full"
            name="base_multiplier"
            type="number"
            step="0.01"
            placeholder="Base Multiplier"
            defaultValue={1.0}
          />
          <input
            className="input w-full"
            name="machine_capacity"
            type="number"
            placeholder="Machine Capacity"
            defaultValue={4}
          />
          <input
            className="input w-full"
            name="unlock_level"
            type="number"
            placeholder="Unlock Level"
            defaultValue={1}
          />
          <button className="btn" type="submit">
            Add Farm Type
          </button>
        </form>
      </div>
    </div>
  );
}

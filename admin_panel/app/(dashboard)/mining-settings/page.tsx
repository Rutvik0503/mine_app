import { requireAdmin } from "@/lib/requireAdmin";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { updateMiningSettings } from "./actions";

export default async function MiningSettingsPage() {
  await requireAdmin();
  const admin = createSupabaseAdminClient();
  const { data: config } = await admin.from("app_config").select("*").limit(1).maybeSingle();

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Mining Settings</h1>
      <p className="text-sm text-[#a0a7c0] mb-6">
        Changes take effect immediately for every user - no app release needed (docs section 53).
      </p>

      <form action={updateMiningSettings} className="panel p-6 max-w-lg space-y-4">
        <div>
          <label className="block text-sm mb-1">Mining Reward Rate (points / TH / hour)</label>
          <input
            className="input w-full"
            type="number"
            step="0.01"
            name="mining_rate"
            defaultValue={config?.mining_rate ?? 1.0}
          />
        </div>
        <div>
          <label className="block text-sm mb-1">Session Duration (minutes)</label>
          <input
            className="input w-full"
            type="number"
            name="max_session_minutes"
            defaultValue={config?.max_session_minutes ?? 60}
          />
        </div>
        <div>
          <label className="block text-sm mb-1">Default Boost Multiplier</label>
          <input
            className="input w-full"
            type="number"
            step="0.01"
            name="default_boost"
            defaultValue={config?.default_boost ?? 1.0}
          />
        </div>
        <div>
          <label className="block text-sm mb-1">Referral Reward (points, each side)</label>
          <input
            className="input w-full"
            type="number"
            step="0.01"
            name="referral_reward"
            defaultValue={config?.referral_reward ?? 50}
          />
        </div>
        <div>
          <label className="block text-sm mb-1">Minimum App Version</label>
          <input
            className="input w-full"
            type="text"
            name="minimum_app_version"
            defaultValue={config?.minimum_app_version ?? "1.0.0"}
          />
        </div>
        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" name="maintenance_mode" defaultChecked={config?.maintenance_mode ?? false} />
          Maintenance mode (blocks new mining sessions)
        </label>

        <button className="btn" type="submit">
          Save Settings
        </button>
      </form>
    </div>
  );
}

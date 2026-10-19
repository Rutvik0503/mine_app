import 'dart:math' as math;

/// Client-side mirror of the server's cost formula (see
/// supabase/functions/_shared/hashrate.ts, farmUpgradeCostForLevel) -
/// DISPLAY ESTIMATE ONLY, so the UI can show a cost/confirmation before the
/// user commits. The actual balance check and deduction always happen
/// server-side in upgrade-farm; this never grants or deducts anything.
class EconomyFormulas {
  EconomyFormulas._();

  static int farmUpgradeCost(int nextLevel) => (500 * math.pow(nextLevel, 1.7)).round();

  /// Mirrors upgradeCostForLevel in _shared/hashrate.ts.
  static int machineUpgradeCost(int nextLevel) => (100 * math.pow(nextLevel, 1.6)).round();
}

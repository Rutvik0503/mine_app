import 'supabase_service.dart';

class AppConfigStatus {
  final bool maintenanceMode;
  final String minimumAppVersion;
  AppConfigStatus({required this.maintenanceMode, required this.minimumAppVersion});
}

/// Reads the admin-controlled app_config row (spec section 9: Splash must
/// check maintenance mode and minimum supported version before letting the
/// user in). Catalog table, readable by any authenticated *or* anonymous
/// session per RLS - this runs before login.
class AppConfigService {
  AppConfigService._();

  static Future<AppConfigStatus> fetchStatus() async {
    final row = await SupabaseService.client
        .from('app_config')
        .select('maintenance_mode, minimum_app_version')
        .limit(1)
        .maybeSingle();
    return AppConfigStatus(
      maintenanceMode: row?['maintenance_mode'] as bool? ?? false,
      minimumAppVersion: row?['minimum_app_version'] as String? ?? '1.0.0',
    );
  }

  /// True if [current] (e.g. "1.2.3") is older than [minimum].
  static bool isBelowMinimum(String current, String minimum) {
    final c = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final m = minimum.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    for (var i = 0; i < m.length; i++) {
      final cv = i < c.length ? c[i] : 0;
      final mv = m[i];
      if (cv != mv) return cv < mv;
    }
    return false;
  }
}

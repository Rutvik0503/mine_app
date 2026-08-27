import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/user_mission_model.dart';

class MissionService {
  final _client = SupabaseService.client;

  Future<List<UserMissionModel>> fetchTodayMissions() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    // Ensures a user_missions row exists for every active mission today
    // (see ensure_daily_missions() in supabase/migrations/0001_init.sql).
    await _client.rpc('ensure_daily_missions');
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await _client
        .from(TableConstant.userMissions)
        .select('*, missions(*)')
        .eq('user_id', userId)
        .eq('date', today);
    return rows.map((e) => UserMissionModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> claimMissionReward(String userMissionId) {
    return SupabaseService.invoke(
      ApiConstant.fnCompleteMission,
      body: {'user_mission_id': userMissionId},
    );
  }
}

import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/mining_session_model.dart';

class MiningService {
  final _client = SupabaseService.client;

  Future<MiningSessionModel?> fetchActiveSession() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from(TableConstant.miningSessions)
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('started_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return MiningSessionModel.fromJson(row);
  }

  Future<List<MiningSessionModel>> fetchHistory({int limit = 20}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.miningSessions)
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false)
        .limit(limit);
    return rows.map((e) => MiningSessionModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> startMining() {
    return SupabaseService.invoke(ApiConstant.fnStartMining);
  }

  Future<Map<String, dynamic>> claimMining(String sessionId) {
    return SupabaseService.invoke(
      ApiConstant.fnClaimMining,
      body: {'session_id': sessionId},
    );
  }
}

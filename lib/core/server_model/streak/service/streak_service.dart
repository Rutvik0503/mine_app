import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/streak_model.dart';

class StreakService {
  final _client = SupabaseService.client;

  Future<StreakModel?> fetchMyStreak() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final row =
        await _client.from(TableConstant.streaks).select().eq('user_id', userId).maybeSingle();
    if (row == null) return null;
    return StreakModel.fromJson(row);
  }

  Future<Map<String, dynamic>> updateStreak() {
    return SupabaseService.invoke(ApiConstant.fnUpdateStreak);
  }
}

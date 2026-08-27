import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/achievement_model.dart';
import '../model/user_achievement_model.dart';

class AchievementService {
  final _client = SupabaseService.client;

  Future<List<AchievementModel>> fetchAll() async {
    final rows = await _client.from(TableConstant.achievements).select().eq('is_active', true);
    return rows.map((e) => AchievementModel.fromJson(e)).toList();
  }

  Future<List<UserAchievementModel>> fetchUnlocked() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows =
        await _client.from(TableConstant.userAchievements).select().eq('user_id', userId);
    return rows.map((e) => UserAchievementModel.fromJson(e)).toList();
  }
}

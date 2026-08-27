import '../model/achievement_model.dart';
import '../model/user_achievement_model.dart';
import '../service/achievement_service.dart';

class AchievementRepository {
  final AchievementService _service = AchievementService();

  Future<List<AchievementModel>> all() => _service.fetchAll();

  Future<List<UserAchievementModel>> unlocked() => _service.fetchUnlocked();
}

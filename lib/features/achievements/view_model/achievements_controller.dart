import 'package:get/get.dart';
import '../../../core/server_model/achievement/model/achievement_model.dart';
import '../../../core/server_model/achievement/model/user_achievement_model.dart';
import '../../../core/server_model/achievement/repository/achievement_repository.dart';

class AchievementsController extends GetxController {
  final AchievementRepository _achievementRepository = AchievementRepository();

  final isLoading = true.obs;
  final all = <AchievementModel>[].obs;
  final unlocked = <UserAchievementModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _achievementRepository.all(),
        _achievementRepository.unlocked(),
      ]);
      all.value = results[0] as List<AchievementModel>;
      unlocked.value = results[1] as List<UserAchievementModel>;
    } finally {
      isLoading.value = false;
    }
  }

  bool isUnlocked(String achievementId) =>
      unlocked.any((u) => u.achievementId == achievementId);
}

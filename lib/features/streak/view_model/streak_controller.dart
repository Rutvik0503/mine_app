import 'package:get/get.dart';
import '../../../core/server_model/streak/model/streak_model.dart';
import '../../../core/server_model/streak/repository/streak_repository.dart';

class StreakController extends GetxController {
  final StreakRepository _streakRepository = StreakRepository();

  final isLoading = true.obs;
  final streak = Rxn<StreakModel>();

  static const milestones = [3, 7, 14, 30, 60, 100];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      streak.value = await _streakRepository.myStreak();
    } finally {
      isLoading.value = false;
    }
  }
}

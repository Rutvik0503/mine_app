import 'package:get/get.dart';
import '../../../core/server_model/leaderboard/model/leaderboard_entry_model.dart';
import '../../../core/server_model/leaderboard/repository/leaderboard_repository.dart';
import '../../../core/services/supabase_service.dart';

class LeaderboardController extends GetxController {
  final LeaderboardRepository _leaderboardRepository = LeaderboardRepository();

  final isLoading = true.obs;
  final category = LeaderboardCategory.hashrate.obs;
  final entries = <LeaderboardEntryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      entries.value = await _leaderboardRepository.fetch(category.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeCategory(LeaderboardCategory c) async {
    category.value = c;
    await load();
  }

  String? get myUserId => SupabaseService.currentUser?.id;
}

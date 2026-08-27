import '../model/leaderboard_entry_model.dart';
import '../service/leaderboard_service.dart';

class LeaderboardRepository {
  final LeaderboardService _service = LeaderboardService();

  Future<List<LeaderboardEntryModel>> fetch(LeaderboardCategory category) => _service.fetch(category);
}

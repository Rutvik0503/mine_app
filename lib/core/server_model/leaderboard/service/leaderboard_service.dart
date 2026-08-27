import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/leaderboard_entry_model.dart';

class LeaderboardService {
  final _client = SupabaseService.client;

  Future<List<LeaderboardEntryModel>> fetch(LeaderboardCategory category, {int limit = 50}) async {
    final column = switch (category) {
      LeaderboardCategory.hashrate => 'total_hashrate',
      LeaderboardCategory.level => 'level',
      LeaderboardCategory.streak => 'streak_days',
    };
    final rows = await _client
        .from(TableConstant.leaderboardPublic)
        .select('id, username, avatar_url, $column')
        .order(column, ascending: false)
        .limit(limit);

    final list = <LeaderboardEntryModel>[];
    for (var i = 0; i < rows.length; i++) {
      final row = Map<String, dynamic>.from(rows[i]);
      row['value'] = row[column];
      list.add(LeaderboardEntryModel.fromJson(row, i + 1));
    }
    return list;
  }
}

import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/leaderboard_entry_model.dart';

class LeaderboardService {
  final _client = SupabaseService.client;

  Future<List<LeaderboardEntryModel>> fetch(LeaderboardCategory category, {int limit = 50}) async {
    if (category == LeaderboardCategory.weeklyXp || category == LeaderboardCategory.monthlyXp) {
      return _fetchXp(category, limit: limit);
    }

    final column = switch (category) {
      LeaderboardCategory.hashrate => 'total_hashrate',
      LeaderboardCategory.level => 'level',
      LeaderboardCategory.streak => 'streak_days',
      _ => 'total_hashrate',
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

  /// Weekly/Monthly XP come from a Postgres function (leaderboard_xp) that
  /// sums the xp_events ledger within the period - profiles.xp is only a
  /// running total, it can't answer "how much this week" on its own.
  Future<List<LeaderboardEntryModel>> _fetchXp(LeaderboardCategory category, {int limit = 50}) async {
    final period = category == LeaderboardCategory.weeklyXp ? 'weekly' : 'monthly';
    final rows = await _client.rpc('leaderboard_xp', params: {'period': period, 'limit_count': limit});

    final list = <LeaderboardEntryModel>[];
    for (var i = 0; i < (rows as List).length; i++) {
      list.add(LeaderboardEntryModel.fromJson(Map<String, dynamic>.from(rows[i]), i + 1));
    }
    return list;
  }
}

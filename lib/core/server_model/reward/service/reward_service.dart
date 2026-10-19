import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/reward_transaction_model.dart';

class RewardService {
  final _client = SupabaseService.client;

  Future<double> fetchAvailableBalance() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;
    final rows = await _client
        .from(TableConstant.rewardTransactions)
        .select('amount')
        .eq('user_id', userId)
        .eq('status', 'completed');
    double total = 0;
    for (final row in rows) {
      total += (row['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<double> fetchPendingBalance() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return 0;
    final rows = await _client
        .from(TableConstant.rewardTransactions)
        .select('amount')
        .eq('user_id', userId)
        .eq('status', 'pending');
    double total = 0;
    for (final row in rows) {
      total += (row['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<List<RewardTransactionModel>> fetchHistory({int limit = 50}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.rewardTransactions)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map((e) => RewardTransactionModel.fromJson(e)).toList();
  }

  /// Rewarded-ad grants (grant-ad-reward) - only call after the ad was
  /// watched to completion.
  Future<Map<String, dynamic>> grantAdReward(String action, {String? sessionId}) {
    return SupabaseService.invoke(
      ApiConstant.fnGrantAdReward,
      body: {'action': action, if (sessionId != null) 'session_id': sessionId},
    );
  }
}

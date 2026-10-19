import '../model/reward_transaction_model.dart';
import '../service/reward_service.dart';

class RewardRepository {
  final RewardService _service = RewardService();

  Future<double> availableBalance() => _service.fetchAvailableBalance();

  Future<double> pendingBalance() => _service.fetchPendingBalance();

  Future<List<RewardTransactionModel>> history({int limit = 50}) => _service.fetchHistory(limit: limit);

  /// How many "free coins" ads are left today.
  Future<int> freeCoinsLeft() async {
    final res = await _service.grantAdReward('status');
    return (res['free_coins_left'] as num?)?.toInt() ?? 0;
  }

  /// How many mining speed-ups are left today (shared across sessions).
  Future<int> speedUpsLeft() async {
    final res = await _service.grantAdReward('status');
    return (res['speed_ups_left'] as num?)?.toInt() ?? 0;
  }

  /// Grants the free coins for a watched ad; returns {coins, free_coins_left}.
  Future<Map<String, dynamic>> claimFreeCoins() => _service.grantAdReward('free_coins');

  /// Makes a running session finish sooner (same reward) for a watched ad.
  Future<Map<String, dynamic>> speedUpSession(String sessionId) =>
      _service.grantAdReward('speed_up', sessionId: sessionId);
}

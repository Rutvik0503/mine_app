import '../model/reward_transaction_model.dart';
import '../service/reward_service.dart';

class RewardRepository {
  final RewardService _service = RewardService();

  Future<double> availableBalance() => _service.fetchAvailableBalance();

  Future<double> pendingBalance() => _service.fetchPendingBalance();

  Future<List<RewardTransactionModel>> history({int limit = 50}) => _service.fetchHistory(limit: limit);
}

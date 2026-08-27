import 'package:get/get.dart';
import '../../../core/server_model/reward/model/reward_transaction_model.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';

class RewardsController extends GetxController {
  final RewardRepository _rewardRepository = RewardRepository();

  final isLoading = true.obs;
  final availableBalance = 0.0.obs;
  final pendingBalance = 0.0.obs;
  final history = <RewardTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _rewardRepository.availableBalance(),
        _rewardRepository.pendingBalance(),
        _rewardRepository.history(),
      ]);
      availableBalance.value = results[0] as double;
      pendingBalance.value = results[1] as double;
      history.value = results[2] as List<RewardTransactionModel>;
    } finally {
      isLoading.value = false;
    }
  }

  double get todayEarned {
    final today = DateTime.now();
    return history
        .where((t) =>
            t.createdAt.year == today.year &&
            t.createdAt.month == today.month &&
            t.createdAt.day == today.day)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalEarned => history.fold(0.0, (sum, t) => sum + t.amount);
}

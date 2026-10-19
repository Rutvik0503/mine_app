import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/server_model/spin/model/spin_status_model.dart';
import '../../../core/server_model/spin/repository/spin_repository.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/analytics_service.dart';

class SpinController extends GetxController {
  final SpinRepository _spinRepository = SpinRepository();
  final RewardRepository _rewardRepository = RewardRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final isSpinning = false.obs;
  final freeSpinsLeft = 0.obs;
  final adSpinsLeft = 0.obs;
  final prizes = <SpinPrize>[].obs;
  final coins = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _spinRepository.status(),
        _rewardRepository.availableBalance(),
      ]);
      _apply(results[0] as SpinStatusModel);
      coins.value = results[1] as double;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _apply(SpinStatusModel status) {
    freeSpinsLeft.value = status.freeSpinsLeft;
    adSpinsLeft.value = status.adSpinsLeft;
    if (status.prizes.isNotEmpty) prizes.value = status.prizes;
  }

  double rewardFor(int segment) =>
      prizes.firstWhereOrNull((p) => p.segment == segment)?.reward ?? 0;

  /// Spins once with a free spin. Returns the server's result for the view
  /// to animate to, or null if nothing was spun.
  Future<SpinStatusModel?> spinFree() async {
    if (isSpinning.value || freeSpinsLeft.value <= 0) return null;
    isSpinning.value = true;
    try {
      final result = await _spinRepository.spinFree();
      _apply(result);
      return result;
    } catch (e) {
      AppSnackbar.error(e.toString());
      isSpinning.value = false;
      return null;
    }
  }

  /// Watches a rewarded ad, then spins with an ad spin.
  Future<SpinStatusModel?> spinWithAd() async {
    if (isSpinning.value || adSpinsLeft.value <= 0) return null;
    isSpinning.value = true;
    try {
      final earned = await AdsService.instance.showRewardedAd(onUserEarnedReward: () {});
      if (!earned) {
        AppSnackbar.info('Ad not ready yet - try again in a moment.'.tr);
        isSpinning.value = false;
        return null;
      }
      await AnalyticsService.logRewardedAdComplete('spin_wheel');
      final result = await _spinRepository.spinWithAd();
      _apply(result);
      return result;
    } catch (e) {
      AppSnackbar.error(e.toString());
      isSpinning.value = false;
      return null;
    }
  }

  /// Called by the view once the wheel animation has landed.
  Future<void> onSpinLanded(SpinStatusModel result) async {
    isSpinning.value = false;
    final reward = result.reward ?? 0;
    if (reward > 0) {
      AppSnackbar.success('spinWon'.trParams({'coins': reward.toStringAsFixed(0)}));
    } else {
      AppSnackbar.info('Better luck next time!'.tr);
    }
    try {
      coins.value = await _rewardRepository.availableBalance();
    } catch (_) {
      // Balance chip just stays stale until the next load.
    }
  }
}

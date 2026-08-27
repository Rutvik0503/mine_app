import 'dart:async';
import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/constant/app_string.dart';
import '../../../core/server_model/boost/model/user_boost_model.dart';
import '../../../core/server_model/boost/repository/boost_repository.dart';
import '../../../core/server_model/mining/model/mining_session_model.dart';
import '../../../core/server_model/mining/repository/mining_repository.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/supabase_service.dart';

class MiningController extends GetxController {
  final MiningRepository _miningRepository = MiningRepository();
  final BoostRepository _boostRepository = BoostRepository();

  final isLoading = true.obs;
  final isStarting = false.obs;
  final isClaiming = false.obs;
  final session = Rxn<MiningSessionModel>();
  final history = <MiningSessionModel>[].obs;
  final activeBoosts = <UserBoostModel>[].obs;
  final remaining = Duration.zero.obs;

  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _miningRepository.activeSession(),
        _miningRepository.history(),
        _boostRepository.activeBoosts(),
      ]);
      session.value = results[0] as MiningSessionModel?;
      history.value = results[1] as List<MiningSessionModel>;
      activeBoosts.value = results[2] as List<UserBoostModel>;
      _startTicker();
    } finally {
      isLoading.value = false;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final s = session.value;
    remaining.value = (s != null && s.isActive) ? s.remaining : Duration.zero;
  }

  bool get canClaim => session.value != null && session.value!.isReadyToClaim;

  Future<void> startMining() async {
    if (!SupabaseService.isLoggedIn) return;
    if (session.value?.isActive == true) {
      AppSnackbar.info(AppString.sessionAlreadyActive);
      return;
    }
    isStarting.value = true;
    try {
      await _miningRepository.startMining();
      await AnalyticsService.logStartMining();
      await load();
      AppSnackbar.success('Mining session started.');
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> claimReward() async {
    final current = session.value;
    if (current == null) return;
    isClaiming.value = true;
    try {
      final result = await _miningRepository.claimMining(current.id);
      final reward = (result['reward'] as num?)?.toDouble() ?? 0;
      await AnalyticsService.logClaimReward(reward);
      AppSnackbar.success('Claimed ${reward.toStringAsFixed(0)} points!');
      await load();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isClaiming.value = false;
    }
  }

  /// Watch a rewarded ad for a temporary non-cash mining boost.
  Future<void> watchAdForBoost() async {
    await AdsService.instance.showRewardedAd(
      onUserEarnedReward: () async {
        await AnalyticsService.logRewardedAdComplete('mining_boost');
        AppSnackbar.success('Boost activated! Refreshing...');
        await load();
      },
    );
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}

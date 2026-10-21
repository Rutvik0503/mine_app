import 'dart:async';
import 'package:get/get.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/constant/app_string.dart';
import '../../../core/server_model/boost/model/user_boost_model.dart';
import '../../../core/server_model/boost/repository/boost_repository.dart';
import '../../../core/server_model/farm/model/farm_model.dart';
import '../../../core/server_model/farm/repository/farm_repository.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';
import '../../../core/server_model/mining/model/mining_session_model.dart';
import '../../../core/server_model/mining/repository/mining_repository.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/server_model/store/model/store_package_model.dart';
import '../../../core/server_model/store/repository/store_repository.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/app_lifecycle_ticker.dart';
import '../view/miner_picker_sheet.dart';

class MiningController extends GetxController with AppLifecycleTicker {
  final MiningRepository _miningRepository = MiningRepository();
  final BoostRepository _boostRepository = BoostRepository();
  final StoreRepository _storeRepository = StoreRepository();
  final FarmRepository _farmRepository = FarmRepository();
  final RewardRepository _rewardRepository = RewardRepository();
  final AuthRepository _authRepository = AuthRepository();
  final MachineRepository _machineRepository = MachineRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final isStarting = false.obs;
  final isClaiming = false.obs;
  final session = Rxn<MiningSessionModel>();
  final history = <MiningSessionModel>[].obs;
  final activeBoosts = <UserBoostModel>[].obs;
  final farm = Rxn<FarmModel>();
  final remaining = Duration.zero.obs;
  final isExtendingWithAd = false.obs;
  final isBuyingTime = false.obs;
  StorePackageModel? _extensionPackage;

  /// Price on the "+60 min" button - Play's localized price once loaded.
  final extraTimePrice = ''.obs;

  Future<void> _loadExtraTimePrice() async {
    try {
      _extensionPackage ??= await _storeRepository.sessionExtensionPackage();
      final package = _extensionPackage;
      if (package == null) return;
      extraTimePrice.value = package.priceLabel;
      final products = await _storeRepository.playProducts([package]);
      final price = products[package.playProductId]?.price;
      if (price != null) extraTimePrice.value = Formatters.storePrice(price);
    } catch (_) {
      // Button keeps the fallback label.
    }
  }

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
        _miningRepository.activeSession(),
        _miningRepository.history(),
        _boostRepository.activeBoosts(),
        _farmRepository.myFarm(),
      ]);
      session.value = results[0] as MiningSessionModel?;
      unawaited(ReminderService.instance.planMiningDone(session.value));
      unawaited(_loadSpeedUpsLeft());
      unawaited(_loadAutoMiningPasses());
      if (extraTimePrice.value.isEmpty) unawaited(_loadExtraTimePrice());
      history.value = results[1] as List<MiningSessionModel>;
      activeBoosts.value = results[2] as List<UserBoostModel>;
      farm.value = results[3] as FarmModel?;
      startTicker();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onTick() {
    final s = session.value;
    remaining.value = (s != null && s.isActive) ? s.remaining : Duration.zero;
  }

  bool get canClaim => session.value != null && session.value!.isReadyToClaim;

  Future<void> startMining() async {
    if (!SupabaseService.isLoggedIn) return;
    if (session.value?.isActive == true) {
      AppSnackbar.info(AppString.sessionAlreadyActive.tr);
      return;
    }
    isStarting.value = true;
    try {
      final machines = (await _machineRepository.myMachines())
          .where((m) => m.status == 'active' && !m.isExpired)
          .toList();
      List<String>? machineIds;
      if (machines.length > 1) {
        // Let the player choose which miners this session runs on.
        isStarting.value = false;
        machineIds = await Get.bottomSheet<List<String>>(
          MinerPickerSheet(machines: machines),
          isScrollControlled: true,
        );
        if (machineIds == null || machineIds.isEmpty) return; // dismissed
        isStarting.value = true;
      } else if (machines.length == 1) {
        machineIds = [machines.first.id];
      }
      await _miningRepository.startMining(machineIds: machineIds);
      await AnalyticsService.logStartMining();
      await load();
      AppSnackbar.success('Mining session started.'.tr);
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> claimReward() => _claim(adBonus: false);

  final isClaimingDouble = false.obs;

  /// "Claim 2x": the player opts into a rewarded ad and, once it's watched
  /// to the end, claims double coins. Skipping the ad claims nothing - the
  /// normal Claim button is still there.
  Future<void> claimDoubleWithAd() async {
    final current = session.value;
    if (current == null || isClaiming.value || isClaimingDouble.value) return;
    isClaimingDouble.value = true;
    try {
      final earned = await AdsService.instance.showRewardedAd(onUserEarnedReward: () {});
      if (!earned) {
        AppSnackbar.info('Ad not ready yet - try again in a moment.'.tr);
        return;
      }
      await AnalyticsService.logRewardedAdComplete('claim_double');
      await _claim(adBonus: true);
    } finally {
      isClaimingDouble.value = false;
    }
  }

  Future<void> _claim({required bool adBonus}) async {
    final current = session.value;
    if (current == null) return;
    isClaiming.value = true;
    try {
      final result = await _miningRepository.claimMining(current.id, adBonus: adBonus);
      final reward = (result['reward'] as num?)?.toDouble() ?? 0;
      final bonus = (result['ad_bonus'] as num?)?.toDouble() ?? 0;
      await AnalyticsService.logClaimReward(reward);
      if (adBonus && bonus <= 0) {
        // Daily 2x limit reached - the normal reward was still claimed.
        AppSnackbar.info('claimedNoBonus'.trParams({'value': reward.toStringAsFixed(0)}));
      } else {
        AppSnackbar.success('claimedPoints'.trParams({'value': reward.toStringAsFixed(0)}));
      }
      // The player just watched an ad for 2x - no interstitial on top.
      if (!adBonus) unawaited(AdsService.instance.maybeShowInterstitialOnClaim());
      await load();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isClaiming.value = false;
    }
  }

  final isWatchingAd = false.obs;
  final isSpeedingUp = false.obs;

  /// Unused referral "24h Auto Mining" passes - the next session uses one.
  final autoMiningPasses = 0.obs;

  Future<void> _loadAutoMiningPasses() async {
    try {
      autoMiningPasses.value = (await _authRepository.currentProfile())?.autoMiningPasses ?? 0;
    } catch (_) {
      // Banner just stays hidden.
    }
  }

  /// Speed-ups left today, across all sessions (null until loaded).
  final speedUpsLeft = Rxn<int>();

  Future<void> _loadSpeedUpsLeft() async {
    try {
      speedUpsLeft.value = await _rewardRepository.speedUpsLeft();
    } catch (_) {
      // Button stays hidden until the count loads.
    }
  }

  /// Opt-in rewarded ad while mining: the session finishes 10 minutes
  /// sooner for the same reward (capped per session by grant-ad-reward).
  Future<void> speedUpWithAd() async {
    final current = session.value;
    if (current == null || !current.canSpeedUpWithAd || isSpeedingUp.value || (speedUpsLeft.value ?? 0) <= 0) {
      return;
    }
    isSpeedingUp.value = true;
    try {
      final earned = await AdsService.instance.showRewardedAd(onUserEarnedReward: () {});
      if (!earned) {
        AppSnackbar.info('Ad not ready yet - try again in a moment.'.tr);
        return;
      }
      await AnalyticsService.logRewardedAdComplete('mining_speed_up');
      final result = await _rewardRepository.speedUpSession(current.id);
      speedUpsLeft.value = (result['speed_ups_left'] as num?)?.toInt() ?? 0;
      AppSnackbar.success('speedUpDone'.trParams({'value': '${result['minutes'] ?? 10}'}));
      await load();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isSpeedingUp.value = false;
    }
  }

  /// Watch a rewarded ad for a temporary non-cash mining boost. The boost is
  /// only ever granted server-side (grant-ad-boost), inside the ad SDK's
  /// confirmed reward callback - never just from tapping the button.
  Future<void> watchAdForBoost() async {
    if (isWatchingAd.value) return;
    isWatchingAd.value = true;
    try {
      final earned = await AdsService.instance.showRewardedAd(
        onUserEarnedReward: () {},
      );
      if (!earned) {
        AppSnackbar.info('Ad not ready yet - try again in a moment.'.tr);
        return;
      }
      await AnalyticsService.logRewardedAdComplete('mining_boost');
      final boostName = await _boostRepository.grantAdBoost();
      AppSnackbar.success('boostActivated'.trParams({'name': boostName}));
      await load();
    } catch (e) {
      AppSnackbar.error('couldNotActivateBoost'.trParams({'error': '$e'}));
    } finally {
      isWatchingAd.value = false;
    }
  }

  /// Free, capped extension of a just-finished session (offered alongside
  /// "Claim Reward" and "Buy More Time" once the countdown hits zero).
  Future<void> watchAdForMoreTime() async {
    final current = session.value;
    if (current == null || !current.canExtendWithAd || isExtendingWithAd.value) return;
    isExtendingWithAd.value = true;
    try {
      final earned = await AdsService.instance.showRewardedAd(
        onUserEarnedReward: () {},
      );
      if (!earned) {
        AppSnackbar.info('Ad not ready yet - try again in a moment.'.tr);
        return;
      }
      await AnalyticsService.logRewardedAdComplete('mining_extension');
      await _miningRepository.extendWithAd(current.id);
      AppSnackbar.success('+15 minutes added to your session!'.tr);
      await load();
    } catch (e) {
      AppSnackbar.error('couldNotExtendSession'.trParams({'error': '$e'}));
    } finally {
      isExtendingWithAd.value = false;
    }
  }

  /// Paid extension of a just-finished session via Google Play.
  Future<void> buyMoreTime() async {
    final current = session.value;
    if (current == null || isBuyingTime.value) return;
    isBuyingTime.value = true;
    try {
      _extensionPackage ??= await _storeRepository.sessionExtensionPackage();
      final package = _extensionPackage;
      if (package == null) {
        AppSnackbar.error('Extra time is not available right now.'.tr);
        return;
      }
      final granted = await _storeRepository.purchase(package, sessionId: current.id);
      if (granted) {
        AppSnackbar.success('minutesAdded'.trParams({'value': '${package.extensionMinutes ?? 0}'}));
      }
      await load();
    } on PurchaseException catch (e) {
      if (!e.canceled) AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('purchaseFailed'.trParams({'error': '$e'}));
    } finally {
      isBuyingTime.value = false;
    }
  }

  @override
  void onClose() {
    stopTicker();
    super.onClose();
  }
}

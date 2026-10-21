import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_lifecycle_ticker.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/server_model/auth/model/profile_model.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/server_model/farm/model/farm_model.dart';
import '../../../core/server_model/farm/repository/farm_repository.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';
import '../../../core/server_model/mining/model/mining_session_model.dart';
import '../../../core/server_model/mining/repository/mining_repository.dart';
import '../../../core/server_model/mission/model/user_mission_model.dart';
import '../../../core/server_model/notification/repository/notification_repository.dart';
import '../../../core/server_model/mission/repository/mission_repository.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/server_model/streak/model/streak_model.dart';
import '../../../core/server_model/streak/repository/streak_repository.dart';
import '../../main_nav/view_model/main_nav_controller.dart';
import '../../mining/view_model/mining_controller.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/analytics_service.dart';

class HomeController extends GetxController with AppLifecycleTicker {
  final AuthRepository _authRepository = AuthRepository();
  final FarmRepository _farmRepository = FarmRepository();
  final MiningRepository _miningRepository = MiningRepository();
  final RewardRepository _rewardRepository = RewardRepository();
  final MissionRepository _missionRepository = MissionRepository();
  final StreakRepository _streakRepository = StreakRepository();
  final MachineRepository _machineRepository = MachineRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();

  final isLoading = true.obs;
  final hasError = false.obs;
  final profile = Rxn<ProfileModel>();
  final farm = Rxn<FarmModel>();
  final activeSession = Rxn<MiningSessionModel>();
  final availableBalance = 0.0.obs;
  final pendingBalance = 0.0.obs;
  final streak = Rxn<StreakModel>();
  final todayMissions = <UserMissionModel>[].obs;
  final remaining = Duration.zero.obs;
  final machineCount = 0.obs;

  /// Coins earned so far by the running session - an estimate for the live
  /// balance ticker; claim-mining computes the real amount server-side.
  final liveSessionReward = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    hasError.value = false;
    unawaited(loadUnreadNotifications());
    try {
      final results = await Future.wait([
        _authRepository.currentProfile(),
        _farmRepository.myFarm(),
        _miningRepository.activeSession(),
        _rewardRepository.availableBalance(),
        _rewardRepository.pendingBalance(),
        _streakRepository.myStreak(),
        _missionRepository.todayMissions(),
        _machineRepository.myMachines(),
      ]);

      profile.value = results[0] as ProfileModel?;
      farm.value = results[1] as FarmModel?;
      activeSession.value = results[2] as MiningSessionModel?;
      availableBalance.value = results[3] as double;
      pendingBalance.value = results[4] as double;
      streak.value = results[5] as StreakModel?;
      todayMissions.value = results[6] as List<UserMissionModel>;
      machineCount.value =
          (results[7] as List<UserMachineModel>).where((m) => !m.isExpired).length;

      startTicker();
      unawaited(_checkInStreak());
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fire-and-forget: server decides if today already counted.
  Future<void> _checkInStreak() async {
    try {
      final result = await _streakRepository.checkIn();
      streak.value = await _streakRepository.myStreak();
      if (result['already_checked_in'] == false) {
        // Show the day's bonus - otherwise players never notice it.
        final coins = (result['coins_awarded'] as num? ?? 0) + (result['level_up_coins'] as num? ?? 0);
        AppSnackbar.success('streakBonusToast'.trParams({
          'days': '${result['current_streak'] ?? 1}',
          'coins': Formatters.points(coins),
          'xp': '${result['xp_awarded'] ?? 0}',
        }));
        availableBalance.value = await _rewardRepository.availableBalance();
      }
      // The player is here today: move tomorrow's reminders forward.
      unawaited(ReminderService.instance.planDaily(streakDays: streak.value?.currentStreak ?? 0));
    } catch (_) {
      // Non-critical - streak will just update next time the dashboard loads.
    }
  }

  @override
  void onTick() {
    final session = activeSession.value;
    if (session == null || !session.isActive) {
      remaining.value = Duration.zero;
      liveSessionReward.value = 0;
      return;
    }
    remaining.value = session.remaining;
    final end = DateTime.now().isBefore(session.expectedEndAt) ? DateTime.now() : session.expectedEndAt;
    final hours = end.difference(session.startedAt).inMilliseconds / Duration.millisecondsPerHour;
    liveSessionReward.value = session.hashrateSnapshot * session.rewardRateSnapshot * hours.clamp(0, double.infinity);
  }

  double get farmProgress {
    final f = farm.value;
    if (f == null) return 0;
    // Level-based progress heuristic; real progress % comes from XP thresholds
    // returned by get-dashboard once the Edge Function is deployed.
    return ((f.level % 10) / 10).clamp(0.0, 1.0);
  }

  // Home/Mining/Farm/Rewards/Profile are IndexedStack tabs inside MainNavView,
  // not standalone named routes - switch tabs instead of Get.toNamed().
  void goToMining() => Get.find<MainNavController>().changeTab(1);

  final isClaiming = false.obs;

  /// The Home card's action: claims right here when the session is ready
  /// (with a spinner while it works), otherwise opens the Mine tab.
  Future<void> onMiningCardTap() async {
    final session = activeSession.value;
    if (session == null || !session.isReadyToClaim) {
      goToMining();
      return;
    }
    if (isClaiming.value) return;
    isClaiming.value = true;
    try {
      final result = await _miningRepository.claimMining(session.id);
      final reward = (result['reward'] as num?)?.toDouble() ?? 0;
      await AnalyticsService.logClaimReward(reward);
      AppSnackbar.success('claimedPoints'.trParams({'value': reward.toStringAsFixed(0)}));
      unawaited(AdsService.instance.maybeShowInterstitialOnClaim());
      await loadDashboard();
      // Keep the Mine tab in step if it's already been opened.
      if (Get.isRegistered<MiningController>()) unawaited(Get.find<MiningController>().load());
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isClaiming.value = false;
    }
  }
  void goToFarm() => Get.find<MainNavController>().changeTab(2);

  void goToRewards() => Get.find<MainNavController>().changeTab(3);

  void goToSpin() => Get.toNamed(AppRoutes.spin);
  void goToMissions() => Get.toNamed(AppRoutes.missions);
  void goToStreak() => Get.toNamed(AppRoutes.streak);
  final unreadNotifications = 0.obs;

  Future<void> loadUnreadNotifications() async {
    try {
      // Reminders the phone showed while the app was closed count too.
      await ReminderService.instance.flushDelivered();
      unreadNotifications.value = await _notificationRepository.unreadCount();
    } catch (_) {
      // Badge just stays as it was.
    }
  }

  Future<void> goToNotifications() async {
    await Get.toNamed(AppRoutes.notifications);
    await loadUnreadNotifications();
  }
  void goToSettings() => Get.toNamed(AppRoutes.settings);

  @override
  void onClose() {
    stopTicker();
    super.onClose();
  }
}

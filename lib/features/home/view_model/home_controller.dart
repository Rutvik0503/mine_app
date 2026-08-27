import 'dart:async';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/auth/model/profile_model.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/server_model/farm/model/farm_model.dart';
import '../../../core/server_model/farm/repository/farm_repository.dart';
import '../../../core/server_model/mining/model/mining_session_model.dart';
import '../../../core/server_model/mining/repository/mining_repository.dart';
import '../../../core/server_model/mission/model/user_mission_model.dart';
import '../../../core/server_model/mission/repository/mission_repository.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/server_model/streak/model/streak_model.dart';
import '../../../core/server_model/streak/repository/streak_repository.dart';

class HomeController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final FarmRepository _farmRepository = FarmRepository();
  final MiningRepository _miningRepository = MiningRepository();
  final RewardRepository _rewardRepository = RewardRepository();
  final MissionRepository _missionRepository = MissionRepository();
  final StreakRepository _streakRepository = StreakRepository();

  final isLoading = true.obs;
  final profile = Rxn<ProfileModel>();
  final farm = Rxn<FarmModel>();
  final activeSession = Rxn<MiningSessionModel>();
  final availableBalance = 0.0.obs;
  final pendingBalance = 0.0.obs;
  final streak = Rxn<StreakModel>();
  final todayMissions = <UserMissionModel>[].obs;
  final remaining = Duration.zero.obs;

  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _authRepository.currentProfile(),
        _farmRepository.myFarm(),
        _miningRepository.activeSession(),
        _rewardRepository.availableBalance(),
        _rewardRepository.pendingBalance(),
        _streakRepository.myStreak(),
        _missionRepository.todayMissions(),
      ]);

      profile.value = results[0] as ProfileModel?;
      farm.value = results[1] as FarmModel?;
      activeSession.value = results[2] as MiningSessionModel?;
      availableBalance.value = results[3] as double;
      pendingBalance.value = results[4] as double;
      streak.value = results[5] as StreakModel?;
      todayMissions.value = results[6] as List<UserMissionModel>;

      _startTicker();
      unawaited(_checkInStreak());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fire-and-forget: server decides if today already counted.
  Future<void> _checkInStreak() async {
    try {
      await _streakRepository.checkIn();
      streak.value = await _streakRepository.myStreak();
    } catch (_) {
      // Non-critical - streak will just update next time the dashboard loads.
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final session = activeSession.value;
    if (session == null || !session.isActive) {
      remaining.value = Duration.zero;
      return;
    }
    remaining.value = session.remaining;
  }

  double get farmProgress {
    final f = farm.value;
    if (f == null) return 0;
    // Level-based progress heuristic; real progress % comes from XP thresholds
    // returned by get-dashboard once the Edge Function is deployed.
    return ((f.level % 10) / 10).clamp(0.0, 1.0);
  }

  void goToMining() => Get.toNamed(AppRoutes.mining);
  void goToMissions() => Get.toNamed(AppRoutes.missions);
  void goToStreak() => Get.toNamed(AppRoutes.streak);
  void goToFarm() => Get.toNamed(AppRoutes.farm);
  void goToNotifications() => Get.toNamed(AppRoutes.notifications);
  void goToSettings() => Get.toNamed(AppRoutes.settings);

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}

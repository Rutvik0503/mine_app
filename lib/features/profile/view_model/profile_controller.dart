import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/achievement/repository/achievement_repository.dart';
import '../../../core/server_model/auth/model/profile_model.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/server_model/farm/model/farm_model.dart';
import '../../../core/server_model/farm/repository/farm_repository.dart';
import '../../../core/server_model/referral/repository/referral_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final FarmRepository _farmRepository = FarmRepository();
  final ReferralRepository _referralRepository = ReferralRepository();
  final AchievementRepository _achievementRepository = AchievementRepository();

  final isLoading = true.obs;
  final profile = Rxn<ProfileModel>();
  final farm = Rxn<FarmModel>();
  final referralCount = 0.obs;
  final achievementCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _authRepository.currentProfile(),
        _farmRepository.myFarm(),
        _referralRepository.myReferrals(),
        _achievementRepository.unlocked(),
      ]);
      profile.value = results[0] as ProfileModel?;
      farm.value = results[1] as FarmModel?;
      referralCount.value = (results[2] as List).length;
      achievementCount.value = (results[3] as List).length;
    } finally {
      isLoading.value = false;
    }
  }

  void goToAchievements() => Get.toNamed(AppRoutes.achievements);
  void goToReferral() => Get.toNamed(AppRoutes.referral);
  void goToLeaderboard() => Get.toNamed(AppRoutes.leaderboard);
  void goToSettings() => Get.toNamed(AppRoutes.settings);

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}

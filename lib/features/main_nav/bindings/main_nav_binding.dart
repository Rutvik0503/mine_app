import 'package:get/get.dart';
import '../../achievements/view_model/achievements_controller.dart';
import '../../farm/view_model/farm_controller.dart';
import '../../home/view_model/home_controller.dart';
import '../../mining/view_model/mining_controller.dart';
import '../../missions/view_model/missions_controller.dart';
import '../../profile/view_model/profile_controller.dart';
import '../../referral/view_model/referral_controller.dart';
import '../../rewards/view_model/rewards_controller.dart';
import '../../streak/view_model/streak_controller.dart';
import '../view_model/main_nav_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => MiningController());
    Get.lazyPut(() => FarmController());
    Get.lazyPut(() => RewardsController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => MissionsController());
    Get.lazyPut(() => StreakController());
    Get.lazyPut(() => ReferralController());
    Get.lazyPut(() => AchievementsController());
  }
}

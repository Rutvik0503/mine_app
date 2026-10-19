import 'package:get/get.dart';
import '../../farm/view_model/farm_controller.dart';
import '../../home/view_model/home_controller.dart';
import '../../mining/view_model/mining_controller.dart';
import '../../profile/view_model/profile_controller.dart';
import '../../rewards/view_model/rewards_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  /// The 5 tabs live in an IndexedStack (kept alive, not rebuilt), so their
  /// controllers only load data once in onInit(). Without this, switching
  /// tabs after an action elsewhere (start mining, claim reward, upgrade...)
  /// shows stale data until a manual pull-to-refresh or hot reload.
  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        Get.find<HomeController>().loadDashboard();
      case 1:
        Get.find<MiningController>().load();
      case 2:
        Get.find<FarmController>().load();
      case 3:
        Get.find<RewardsController>().load();
      case 4:
        Get.find<ProfileController>().load();
    }
  }
}

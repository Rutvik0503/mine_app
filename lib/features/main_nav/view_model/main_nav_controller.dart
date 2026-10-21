import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/constant/app_color.dart';
import '../../farm/view_model/farm_controller.dart';
import '../../home/view_model/home_controller.dart';
import '../../mining/view_model/mining_controller.dart';
import '../../profile/view_model/profile_controller.dart';
import '../../rewards/view_model/rewards_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  DateTime? _lastHomeBack;
  bool _exitDialogOpen = false;

  /// System back: other tabs return to Home; on Home the first press only
  /// hints, a second press within 2s asks before leaving the app.
  Future<void> handleBack() async {
    if (currentIndex.value != 0) {
      changeTab(0);
      return;
    }
    final now = DateTime.now();
    final last = _lastHomeBack;
    if (last == null || now.difference(last) > const Duration(seconds: 2)) {
      _lastHomeBack = now;
      AppSnackbar.info('pressBackAgainToExit'.tr);
      return;
    }
    _lastHomeBack = null;
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    final exit = await Get.dialog<bool>(
      AlertDialog(
        title: Text('exitAppTitle'.tr),
        content: Text('exitAppMessage'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColor.error),
            child: Text('Exit'.tr),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (exit == true) await SystemNavigator.pop();
  }

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

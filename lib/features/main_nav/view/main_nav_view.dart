import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/bottom_navbar.dart';
import '../../farm/view/farm_view.dart';
import '../../home/view/home_view.dart';
import '../../mining/view/mining_view.dart';
import '../../profile/view/profile_view.dart';
import '../../rewards/view/rewards_view.dart';
import '../view_model/main_nav_controller.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeView(),
      MiningView(),
      FarmView(),
      RewardsView(),
      ProfileView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(index: controller.currentIndex.value, children: pages),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/ad_banner_widget.dart';
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
        body: IndexedStack(
          index: controller.currentIndex.value,
          // Hidden tabs stay alive but their animations shouldn't keep ticking.
          children: [
            for (var i = 0; i < pages.length; i++)
              TickerMode(enabled: i == controller.currentIndex.value, child: pages[i]),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // One shared banner for Home / Mine / Farm / Rewards. Same tree
            // position on those tabs so switching between them keeps the
            // loaded ad; Profile (settings, account deletion) stays ad-free.
            // Its own vertical padding keeps it clear of the tab buttons
            // (no accidental taps).
            if (controller.currentIndex.value <= 3) const AdBannerWidget(key: ValueKey('main-banner')),
            AppBottomNavBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
            ),
          ],
        ),
      ),
    );
  }
}

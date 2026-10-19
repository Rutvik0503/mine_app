import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_color.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColor.surface,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: 'Home'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.hardware_rounded), label: 'Mine'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.dns_rounded), label: 'Farm'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.toll_rounded), label: 'Rewards'.tr),
        BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: 'Profile'.tr),
      ],
    );
  }
}

import 'package:flutter/material.dart';
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: 'Mine'),
        BottomNavigationBarItem(icon: Icon(Icons.agriculture_rounded), label: 'Farm'),
        BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_rounded), label: 'Rewards'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}

import 'package:flutter/material.dart';

/// Original color system for Virtual Mining Empire.
/// Dark, energy/industrial theme distinct from competitor apps.
class AppColor {
  AppColor._();

  static const Color background = Color(0xFF0B0F1A);
  static const Color surface = Color(0xFF141A2A);
  static const Color surfaceElevated = Color(0xFF1C2338);
  static const Color border = Color(0xFF2A3350);

  static const Color primary = Color(0xFFFF8A1E); // ember orange
  static const Color primaryDark = Color(0xFFCC6C12);
  static const Color secondary = Color(0xFF3DDC97); // hashrate green
  static const Color accent = Color(0xFF5B8CFF); // boost blue

  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFFA0A7C0);
  static const Color textDisabled = Color(0xFF5C6280);

  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFC145);
  static const Color error = Color(0xFFFF5C6C);

  static const List<Color> miningGradient = [Color(0xFFFF8A1E), Color(0xFFFF5C6C)];
  static const List<Color> hashrateGradient = [Color(0xFF3DDC97), Color(0xFF1E9E6B)];
  static const List<Color> premiumGradient = [Color(0xFFFFC145), Color(0xFFFF8A1E)];
}

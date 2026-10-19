import 'package:flutter/material.dart';

/// Original color system for Virtual Mining Empire.
/// Neutrals (background/surface/border/text) switch between a dark and a
/// light palette via [setDark] - see ThemeService, which is the only thing
/// that should call it. Brand/semantic colors (primary/secondary/accent/
/// success/warning/error/gradients) stay constant across both themes.
class AppColor {
  AppColor._();

  static bool _isDark = true;

  static void setDark(bool isDark) => _isDark = isDark;

  static Color get background => _isDark ? const Color(0xFF050907) : const Color(0xFFF6FAF7);
  static Color get surface => _isDark ? const Color(0xFF0D1510) : const Color(0xFFFFFFFF);
  static Color get surfaceElevated => _isDark ? const Color(0xFF15211A) : const Color(0xFFEAF3ED);
  static Color get border => _isDark ? const Color(0xFF1E3326) : const Color(0xFFDCE8E0);

  static const Color primary = Color(0xFF4CD97B); // mining green
  static const Color primaryDark = Color(0xFF1F9D52);
  static const Color secondary = Color(0xFF3DDC97); // hashrate green
  static const Color accent = Color(0xFF5B8CFF); // boost blue

  static Color get textPrimary => _isDark ? const Color(0xFFF5F6FA) : const Color(0xFF14161F);
  static Color get textSecondary => _isDark ? const Color(0xFF9DB3A5) : const Color(0xFF52665A);
  static Color get textDisabled => _isDark ? const Color(0xFF55685C) : const Color(0xFFB2C2B8);

  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFC145);
  static const Color error = Color(0xFFFF5C6C);

  static const List<Color> miningGradient = [Color(0xFF4CD97B), Color(0xFF1F9D52)];
  static const List<Color> hashrateGradient = [Color(0xFF3DDC97), Color(0xFF1E9E6B)];
  static const List<Color> premiumGradient = [Color(0xFFFFC145), Color(0xFFFF8A1E)];
}

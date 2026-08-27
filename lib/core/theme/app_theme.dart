import 'package:flutter/material.dart';
import '../constant/app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColor.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        surface: AppColor.surface,
        error: AppColor.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColor.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColor.textPrimary,
        displayColor: AppColor.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColor.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColor.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColor.textDisabled),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColor.surface,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.textDisabled,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerColor: AppColor.border,
    );
  }
}

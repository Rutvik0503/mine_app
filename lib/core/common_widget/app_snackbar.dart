import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/app_color.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(String message) => _show('Success', message, AppColor.success);
  static void error(String message) => _show('Error', message, AppColor.error);
  static void info(String message) => _show('Info', message, AppColor.accent);

  static void _show(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColor.surfaceElevated,
      colorText: AppColor.textPrimary,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      borderColor: color,
      borderWidth: 1,
      duration: const Duration(seconds: 3),
    );
  }
}

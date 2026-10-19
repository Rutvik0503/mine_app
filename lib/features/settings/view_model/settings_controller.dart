import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/reminder_service.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/constant/legal_content.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/theme_service.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final notificationsEnabled = ReminderService.instance.isEnabled.obs;

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await ReminderService.instance.setEnabled(value);
  }
  final soundEnabled = true.obs;
  final hapticEnabled = true.obs;
  final appVersion = ''.obs;
  final showAdPrivacyOptions = false.obs;

  bool get isDarkTheme => ThemeService.isDark.value;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
    _loadAdPrivacyOptions();
  }

  Future<void> _loadAdPrivacyOptions() async {
    showAdPrivacyOptions.value = await AdsService.instance.isPrivacyOptionsRequired();
  }

  Future<void> openAdPrivacyOptions() => AdsService.instance.showPrivacyOptions();

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> setDarkTheme(bool value) => ThemeService.setDark(value);

  Future<void> logout() async {
    await ReminderService.instance.cancelAll();
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  final isDeletingAccount = false.obs;

  /// Google Play requires in-app account deletion. Confirms first - this
  /// can't be undone - then deletes server-side (delete-account) and signs out.
  Future<void> deleteAccountRequest() async {
    if (isDeletingAccount.value) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete your account?'.tr),
        content: Text('deleteAccountWarning'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColor.error),
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isDeletingAccount.value = true;
    try {
      await _authRepository.deleteAccount();
      await ReminderService.instance.cancelAll();
      try {
        await _authRepository.logout();
      } catch (_) {
        // The session died with the account - only the local copy is left.
      }
      Get.offAllNamed(AppRoutes.login);
      AppSnackbar.success('Your account has been deleted.'.tr);
    } catch (e) {
      AppSnackbar.error('couldNotDeleteAccount'.trParams({'error': '$e'}));
    } finally {
      isDeletingAccount.value = false;
    }
  }

  String? get userEmail => SupabaseService.currentUser?.email;

  void openPrivacyPolicy() => Get.toNamed(
        AppRoutes.legalPage,
        arguments: {'title': 'Privacy Policy', 'body': LegalContent.privacyPolicy},
      );

  void openTerms() => Get.toNamed(
        AppRoutes.legalPage,
        arguments: {'title': 'Terms of Service', 'body': LegalContent.termsOfService},
      );

  void openHelp() => Get.toNamed(
        AppRoutes.legalPage,
        arguments: {'title': 'Help & Support', 'body': LegalContent.helpFaq, 'showContact': true},
      );
}

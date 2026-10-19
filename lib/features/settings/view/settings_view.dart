import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/services/language_service.dart';
import '../view_model/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PrimaryAppBar(title: 'Settings'.tr),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppText.caption(controller.userEmail ?? ''),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                SwitchListTile(
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.setNotificationsEnabled,
                  title: Text('Notifications'.tr),
                  activeThumbColor: AppColor.primary,
                ),
                SwitchListTile(
                  value: controller.soundEnabled.value,
                  onChanged: (v) => controller.soundEnabled.value = v,
                  title: Text('Sound'.tr),
                  activeThumbColor: AppColor.primary,
                ),
                SwitchListTile(
                  value: controller.hapticEnabled.value,
                  onChanged: (v) => controller.hapticEnabled.value = v,
                  title: Text('Haptic Feedback'.tr),
                  activeThumbColor: AppColor.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  title: Text('Language'.tr),
                  trailing: Text(LanguageService.labelFor(LanguageService.locale.value)),
                  onTap: () => _showLanguagePicker(context),
                ),
                SwitchListTile(
                  value: controller.isDarkTheme,
                  onChanged: controller.setDarkTheme,
                  title: Text('Dark Theme'.tr),
                  activeThumbColor: AppColor.primary,
                ),
                ListTile(title: Text('Privacy Policy'.tr), onTap: controller.openPrivacyPolicy),
                ListTile(title: Text('Terms of Service'.tr), onTap: controller.openTerms),
                ListTile(title: Text('Help & Support'.tr), onTap: controller.openHelp),
                // Required by Google for EEA/UK users; hidden everywhere else.
                if (controller.showAdPrivacyOptions.value)
                  ListTile(title: Text('Ad privacy choices'.tr), onTap: controller.openAdPrivacyOptions),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  title: Text('Delete Account'.tr, style: const TextStyle(color: AppColor.error)),
                  onTap: controller.deleteAccountRequest,
                ),
                ListTile(
                  title: Text('Logout'.tr, style: const TextStyle(color: AppColor.error)),
                  onTap: controller.logout,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(child: AppText.caption('versionLabel'.trParams({'value': controller.appVersion.value}))),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Language'.tr),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageService.supported
                .map(
                  (locale) => RadioListTile<Locale>(
                    value: locale,
                    // ignore: deprecated_member_use
                    groupValue: LanguageService.locale.value,
                    title: Text(LanguageService.labelFor(locale)),
                    activeColor: AppColor.primary,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      if (value != null) LanguageService.setLocale(value);
                      Get.back();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.border),
      ),
      child: Column(children: children),
    );
  }
}

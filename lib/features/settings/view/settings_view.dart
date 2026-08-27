import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const PrimaryAppBar(title: 'Settings'),
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
                  onChanged: (v) => controller.notificationsEnabled.value = v,
                  title: const Text('Notifications'),
                  activeThumbColor: AppColor.primary,
                ),
                SwitchListTile(
                  value: controller.soundEnabled.value,
                  onChanged: (v) => controller.soundEnabled.value = v,
                  title: const Text('Sound'),
                  activeThumbColor: AppColor.primary,
                ),
                SwitchListTile(
                  value: controller.hapticEnabled.value,
                  onChanged: (v) => controller.hapticEnabled.value = v,
                  title: const Text('Haptic Feedback'),
                  activeThumbColor: AppColor.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(title: const Text('Language'), trailing: const Text('English')),
                const ListTile(title: Text('Theme'), trailing: Text('Dark')),
                ListTile(title: const Text('Privacy Policy'), onTap: controller.openPrivacyPolicy),
                ListTile(title: const Text('Terms of Service'), onTap: controller.openTerms),
                ListTile(title: const Text('Help & Support'), onTap: controller.openHelp),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                ListTile(
                  title: const Text('Delete Account', style: TextStyle(color: AppColor.error)),
                  onTap: controller.deleteAccountRequest,
                ),
                ListTile(
                  title: const Text('Logout', style: TextStyle(color: AppColor.error)),
                  onTap: controller.logout,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(child: AppText.caption('Version ${controller.appVersion.value}')),
          ],
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

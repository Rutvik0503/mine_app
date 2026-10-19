import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/constant/app_color.dart';

/// Shown when the installed app is below app_config.minimum_app_version
/// (spec section 9/54). No retry-into-app path - the only way out is
/// actually updating, so this intentionally has no back navigation.
class UpdateRequiredView extends StatelessWidget {
  const UpdateRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update_alt_rounded, size: 64, color: AppColor.primary),
                const SizedBox(height: 20),
                AppText.heading('Update Required'.tr, align: TextAlign.center),
                const SizedBox(height: 10),
                AppText.caption(
                  'A newer version of the app is required to continue.'.tr,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 28),
                AppButton(label: 'Update Now'.tr, onPressed: _openStoreListing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStoreListing() async {
    final info = await PackageInfo.fromPlatform();
    final uri = Uri.parse('market://details?id=${info.packageName}');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=${info.packageName}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constant/legal_content.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';

/// Generic static-content page used for Privacy Policy, Terms of Service and
/// Help & Support - avoids duplicating this scaffold three times for what is
/// otherwise just a title + body of text. Reads {'title', 'body',
/// 'showContact'} from Get.arguments.
class LegalPageView extends StatelessWidget {
  const LegalPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? const {};
    final title = args['title'] as String? ?? '';
    final body = args['body'] as String? ?? '';
    final showContact = args['showContact'] as bool? ?? false;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PrimaryAppBar(title: title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: AppText(body, size: 14, color: AppColor.textSecondary),
                ),
              ),
              if (showContact) ...[
                const SizedBox(height: 16),
                AppButton(
                  label: 'Contact Support',
                  icon: Icons.mail_outline_rounded,
                  onPressed: () => launchUrl(Uri.parse('mailto:${LegalContent.supportEmail}?subject=Virtual%20Mining%20Empire%20support')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

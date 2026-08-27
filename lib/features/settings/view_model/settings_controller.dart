import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/services/supabase_service.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final notificationsEnabled = true.obs;
  final soundEnabled = true.obs;
  final hapticEnabled = true.obs;
  final appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> deleteAccountRequest() async {
    // Deleting a user requires the service_role key and must run server-side
    // (see supabase/functions - add a `delete-account` Edge Function before
    // wiring this button to a real destructive action).
    AppSnackbar.info('Account deletion requests are reviewed by support. Contact us to proceed.');
  }

  String? get userEmail => SupabaseService.currentUser?.email;

  // Point these at your real, hosted policy pages before release.
  Future<void> openPrivacyPolicy() => _openUrl('https://example.com/privacy');
  Future<void> openTerms() => _openUrl('https://example.com/terms');
  Future<void> openHelp() => _openUrl('https://example.com/help');

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppSnackbar.error('Could not open link.');
    }
  }
}

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
import '../../../core/services/app_config_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/supabase_service.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Splash responsibilities (spec section 9): check maintenance mode and
    // minimum supported version before anything else, then check auth.
    try {
      await Future.delayed(const Duration(milliseconds: 900));

      final status = await AppConfigService.fetchStatus();
      if (status.maintenanceMode) {
        Get.offAllNamed(AppRoutes.maintenance);
        return;
      }

      final info = await PackageInfo.fromPlatform();
      if (AppConfigService.isBelowMinimum(info.version, status.minimumAppVersion)) {
        Get.offAllNamed(AppRoutes.updateRequired);
        return;
      }

      if (!SupabaseService.isLoggedIn) {
        _goToOnboardingOrAuth();
        return;
      }

      final profile = await _authRepository.currentProfile();
      if (profile == null) {
        // Auth session exists but profile row missing - fall back to login.
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (_) {
      // Never leave the user stuck on the splash screen.
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void _goToOnboardingOrAuth() {
    if (SessionService.hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}

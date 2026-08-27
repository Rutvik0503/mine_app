import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/auth/repository/auth_repository.dart';
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
    // Splash responsibilities: check auth session, load profile,
    // check maintenance mode (app_config, see AppConfigService in Profile/Settings).
    await Future.delayed(const Duration(milliseconds: 900));

    if (!SupabaseService.isLoggedIn) {
      _goToOnboardingOrAuth();
      return;
    }

    try {
      final profile = await _authRepository.currentProfile();
      if (profile == null) {
        // Auth session exists but profile row missing - fall back to login.
        Get.offAllNamed(AppRoutes.login);
        return;
      }
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (_) {
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

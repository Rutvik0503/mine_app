import 'package:get/get.dart';
import '../../features/achievements/bindings/achievements_binding.dart';
import '../../features/achievements/view/achievements_view.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/forgot_password/view/forgot_password_view.dart';
import '../../features/auth/login/view/login_view.dart';
import '../../features/auth/signup/view/signup_view.dart';
import '../../features/leaderboard/bindings/leaderboard_binding.dart';
import '../../features/leaderboard/view/leaderboard_view.dart';
import '../../features/machine/bindings/machine_binding.dart';
import '../../features/machine/view/machine_detail_view.dart';
import '../../features/machine/view/machine_list_view.dart';
import '../../features/main_nav/bindings/main_nav_binding.dart';
import '../../features/main_nav/view/main_nav_view.dart';
import '../../features/missions/bindings/missions_binding.dart';
import '../../features/missions/view/missions_view.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/notifications/view/notifications_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/view/onboarding_view.dart';
import '../../features/referral/view/referral_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/view/settings_view.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/streak/view/streak_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginView(), binding: AuthBinding()),
    GetPage(name: AppRoutes.signup, page: () => const SignupView(), binding: AuthBinding()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: AppRoutes.machineList,
      page: () => const MachineListView(),
      binding: MachineBinding(),
    ),
    GetPage(
      name: AppRoutes.machineDetail,
      page: () => const MachineDetailView(),
      binding: MachineBinding(),
    ),
    GetPage(
      name: AppRoutes.missions,
      page: () => const MissionsView(),
      binding: MissionsBinding(),
    ),
    GetPage(name: AppRoutes.streak, page: () => const StreakView(), binding: MainNavBinding()),
    GetPage(
      name: AppRoutes.referral,
      page: () => const ReferralView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: AppRoutes.achievements,
      page: () => const AchievementsView(),
      binding: AchievementsBinding(),
    ),
    GetPage(
      name: AppRoutes.leaderboard,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}

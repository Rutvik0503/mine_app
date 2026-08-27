import 'package:get/get.dart';
import '../../../core/constant/app_string.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/session_service.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final String icon; // material icon name mapped in view

  const OnboardingSlide(this.title, this.description, this.icon);
}

class OnboardingController extends GetxController {
  final pageIndex = 0.obs;

  final slides = const [
    OnboardingSlide(AppString.onboardTitle1, AppString.onboardDesc1, 'agriculture'),
    OnboardingSlide(AppString.onboardTitle2, AppString.onboardDesc2, 'bolt'),
    OnboardingSlide(AppString.onboardTitle3, AppString.onboardDesc3, 'checklist'),
    OnboardingSlide(AppString.onboardTitle4, AppString.onboardDesc4, 'emoji_events'),
  ];

  void onPageChanged(int index) => pageIndex.value = index;

  bool get isLast => pageIndex.value == slides.length - 1;

  Future<void> finish() async {
    await SessionService.setOnboardingSeen();
    Get.offAllNamed(AppRoutes.login);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_button.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/mining_visuals.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/onboarding_controller.dart';

Widget _hero(String key) {
  switch (key) {
    case 'agriculture':
      return const SwingingPickaxe(size: 74, color: AppColor.primary);
    case 'bolt':
      return const SpinningGear(size: 78, color: AppColor.primary, seconds: 5);
    case 'checklist':
      return const PulseGlow(child: Icon(Icons.toll_rounded, size: 64, color: AppColor.warning));
    default:
      return const PulseGlow(child: Icon(Icons.emoji_events_rounded, size: 64, color: AppColor.warning));
  }
}

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.finish,
                child: AppText('Skip'.tr, color: AppColor.textSecondary),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.slides.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final slide = controller.slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColor.border),
                          ),
                          child: Center(child: _hero(slide.icon)),
                        ),
                        const SizedBox(height: 36),
                        AppText.heading(slide.title.tr, align: TextAlign.center),
                        const SizedBox(height: 12),
                        AppText(
                          slide.description.tr,
                          align: TextAlign.center,
                          color: AppColor.textSecondary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: controller.pageIndex.value == i ? 24 : 8,
                    decoration: BoxDecoration(
                      color: controller.pageIndex.value == i ? AppColor.primary : AppColor.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(
                () => AppButton(
                  label: (controller.isLast ? 'Get Started' : 'Next').tr,
                  onPressed: () {
                    if (controller.isLast) {
                      controller.finish();
                    } else {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

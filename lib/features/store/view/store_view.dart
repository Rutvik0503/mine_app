import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/ad_banner_widget.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/free_coins_card.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/common_widget/primary_app_bar.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/store_controller.dart';

class StoreView extends GetView<StoreController> {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: PrimaryAppBar(title: 'Buy Coins'.tr),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const FreeCoinsCard(padding: EdgeInsets.only(bottom: 16)),
            AppText.caption(
              'Spend coins on miners, farm upgrades and machine upgrades. Coins are virtual and have no cash value.'.tr,
            ),
            const SizedBox(height: 16),
            if (controller.packages.isEmpty)
              EmptyStateWidget(message: 'No packages available right now.'.tr)
            else
              ...controller.packages.map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColor.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColor.premiumGradient),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.toll_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(p.name, weight: FontWeight.w700),
                            const SizedBox(height: 2),
                            if (p.description != null) AppText.caption(p.description!.tr),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 104,
                        child: ElevatedButton(
                          onPressed: controller.purchasingId.value == p.id
                              ? null
                              : () => controller.buy(p),
                          child: controller.purchasingId.value == p.id
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(controller.priceFor(p)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const AdBannerWidget(),
          ],
        );
      }),
    );
  }
}

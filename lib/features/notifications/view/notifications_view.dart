import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/constant/app_color.dart';
import '../view_model/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const AppText.subHeading('Notifications'),
        actions: [
          TextButton(onPressed: controller.markAllRead, child: const Text('Mark all read')),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.notifications.isEmpty) {
          return const EmptyStateWidget(message: 'No notifications yet.', icon: Icons.notifications_none_rounded);
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final n = controller.notifications[index];
              return GestureDetector(
                onTap: () => controller.markRead(n),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.isRead ? AppColor.surface : AppColor.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: n.isRead ? AppColor.border : AppColor.primary),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                        color: n.isRead ? AppColor.textDisabled : AppColor.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(n.title, weight: FontWeight.w700),
                            const SizedBox(height: 4),
                            AppText.caption(n.body),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

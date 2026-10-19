import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_text.dart';
import '../../../core/common_widget/empty_state_widget.dart';
import '../../../core/common_widget/loading_overlay.dart';
import '../../../core/constant/app_color.dart';
import '../../../core/server_model/notification/model/app_notification_model.dart';
import '../view_model/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: AppText.subHeading('Notifications'.tr),
        actions: [
          Obx(
            () => controller.unreadCount == 0
                ? const SizedBox.shrink()
                : TextButton.icon(
                    onPressed: controller.markAllRead,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: Text('Mark all read'.tr),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingOverlay();
        if (controller.notifications.isEmpty) {
          // Still pull-to-refresh-able, so a just-arrived one can be fetched.
          return RefreshIndicator(
            onRefresh: controller.load,
            color: AppColor.primary,
            child: LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: EmptyStateWidget(
                      message: 'No notifications yet.'.tr,
                      icon: Icons.notifications_none_rounded,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColor.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: controller.notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final unread = controller.unreadCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: AppText.caption(
                    unread == 0 ? 'All caught up ✨'.tr : 'unreadCount'.trParams({'n': '$unread'}),
                  ),
                );
              }
              final n = controller.notifications[index - 1];
              return _NotificationTile(notification: n, onTap: () => controller.markRead(n));
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  static (IconData, Color) _style(String type) => switch (type) {
        'streak' => (Icons.local_fire_department_rounded, const Color(0xFFFF8A1E)),
        'daily_bonus' => (Icons.card_giftcard_rounded, AppColor.warning),
        'mining' => (Icons.hardware_rounded, AppColor.primary),
        'rental' => (Icons.hourglass_bottom_rounded, AppColor.warning),
        'referral' => (Icons.people_alt_rounded, AppColor.accent),
        'reengagement' => (Icons.waving_hand_rounded, AppColor.accent),
        _ => (Icons.notifications_rounded, AppColor.primary),
      };

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now'.tr;
    if (d.inMinutes < 60) return 'minutesAgo'.trParams({'n': '${d.inMinutes}'});
    if (d.inHours < 24) return 'hoursAgo'.trParams({'n': '${d.inHours}'});
    if (d.inDays < 7) return 'daysAgo'.trParams({'n': '${d.inDays}'});
    return '${t.day}/${t.month}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, color) = _style(n.type);
    final unread = !n.isRead;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppColor.primary.withValues(alpha: 0.10) : AppColor.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: unread ? AppColor.primary.withValues(alpha: 0.8) : AppColor.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: unread ? 0.20 : 0.10),
              ),
              child: Icon(icon, color: unread ? color : color.withValues(alpha: 0.6), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          n.title,
                          weight: unread ? FontWeight.w800 : FontWeight.w500,
                          size: 14,
                          color: unread ? AppColor.textPrimary : AppColor.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppText(_ago(n.createdAt), size: 11, color: AppColor.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText.caption(n.body),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 9,
                height: 9,
                decoration: const BoxDecoration(color: AppColor.primary, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

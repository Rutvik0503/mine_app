import 'package:get/get.dart';
import '../../../core/server_model/notification/model/app_notification_model.dart';
import '../../../core/server_model/notification/repository/notification_repository.dart';
import '../../../core/services/reminder_service.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _notificationRepository = NotificationRepository();

  final isLoading = true.obs;
  final notifications = <AppNotificationModel>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = notifications.isEmpty;
    try {
      // Reminders the phone showed while the app was closed go in first.
      await ReminderService.instance.flushDelivered();
      notifications.value = await _notificationRepository.all();
    } finally {
      isLoading.value = false;
    }
  }

  /// Un-highlights straight away; the server catches up in the background.
  Future<void> markRead(AppNotificationModel n) async {
    if (n.isRead) return;
    final i = notifications.indexWhere((x) => x.id == n.id);
    if (i >= 0) notifications[i] = n.copyWith(isRead: true);
    try {
      await _notificationRepository.markRead(n.id);
    } catch (_) {
      if (i >= 0) notifications[i] = n; // put the highlight back
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount == 0) return;
    final before = notifications.toList();
    notifications.value = [for (final n in notifications) n.copyWith(isRead: true)];
    try {
      await _notificationRepository.markAllRead();
    } catch (_) {
      notifications.value = before;
    }
  }
}

import 'package:get/get.dart';
import '../../../core/server_model/notification/model/app_notification_model.dart';
import '../../../core/server_model/notification/repository/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _notificationRepository = NotificationRepository();

  final isLoading = true.obs;
  final notifications = <AppNotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      notifications.value = await _notificationRepository.all();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(AppNotificationModel n) async {
    if (n.isRead) return;
    await _notificationRepository.markRead(n.id);
    await load();
  }

  Future<void> markAllRead() async {
    await _notificationRepository.markAllRead();
    await load();
  }
}

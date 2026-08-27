import '../model/app_notification_model.dart';
import '../service/notification_data_service.dart';

class NotificationRepository {
  final NotificationDataService _service = NotificationDataService();

  Future<List<AppNotificationModel>> all() => _service.fetchAll();

  Future<void> markRead(String id) => _service.markRead(id);

  Future<void> markAllRead() => _service.markAllRead();
}

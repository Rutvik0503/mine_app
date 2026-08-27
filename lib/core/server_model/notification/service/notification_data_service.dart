import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/app_notification_model.dart';

/// Reads/writes the `notifications` table. Named "data" service to avoid
/// clashing with core/services/push_notification_service.dart (FCM wrapper).
class NotificationDataService {
  final _client = SupabaseService.client;

  Future<List<AppNotificationModel>> fetchAll() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.notifications)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map((e) => AppNotificationModel.fromJson(e)).toList();
  }

  Future<void> markRead(String id) async {
    await _client.from(TableConstant.notifications).update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllRead() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    await _client
        .from(TableConstant.notifications)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}

import '../model/streak_model.dart';
import '../service/streak_service.dart';

class StreakRepository {
  final StreakService _service = StreakService();

  Future<StreakModel?> myStreak() => _service.fetchMyStreak();

  /// Server's check-in result: `already_checked_in`, and when false the
  /// `current_streak`, `coins_awarded`, `xp_awarded` and `level_up_coins`.
  Future<Map<String, dynamic>> checkIn() => _service.updateStreak();
}

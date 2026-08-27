import '../model/streak_model.dart';
import '../service/streak_service.dart';

class StreakRepository {
  final StreakService _service = StreakService();

  Future<StreakModel?> myStreak() => _service.fetchMyStreak();

  Future<void> checkIn() => _service.updateStreak();
}

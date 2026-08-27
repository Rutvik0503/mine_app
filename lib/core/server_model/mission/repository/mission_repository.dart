import '../model/user_mission_model.dart';
import '../service/mission_service.dart';

class MissionRepository {
  final MissionService _service = MissionService();

  Future<List<UserMissionModel>> todayMissions() => _service.fetchTodayMissions();

  Future<void> claimReward(String userMissionId) => _service.claimMissionReward(userMissionId);
}

import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/server_model/mission/model/user_mission_model.dart';
import '../../../core/server_model/mission/repository/mission_repository.dart';
import '../../../core/services/analytics_service.dart';

class MissionsController extends GetxController {
  final MissionRepository _missionRepository = MissionRepository();

  final isLoading = true.obs;
  final claimingId = Rxn<String>();
  final missions = <UserMissionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      missions.value = await _missionRepository.todayMissions();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> claim(UserMissionModel mission) async {
    if (mission.status != 'completed') return;
    claimingId.value = mission.id;
    try {
      await _missionRepository.claimReward(mission.id);
      await AnalyticsService.logMissionComplete(mission.missionId);
      AppSnackbar.success('Mission reward claimed!'.tr);
      await load();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      claimingId.value = null;
    }
  }
}

import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';
import '../../../core/services/analytics_service.dart';

class MachineController extends GetxController {
  final MachineRepository _machineRepository = MachineRepository();

  final isLoading = true.obs;
  final upgradingId = Rxn<String>();
  final myMachines = <UserMachineModel>[].obs;
  final selected = Rxn<UserMachineModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      myMachines.value = await _machineRepository.myMachines();
    } finally {
      isLoading.value = false;
    }
  }

  void openDetail(UserMachineModel machine) {
    selected.value = machine;
    Get.toNamed(AppRoutes.machineDetail);
  }

  Future<void> upgrade(UserMachineModel machine) async {
    upgradingId.value = machine.id;
    try {
      await _machineRepository.upgrade(machine.id);
      await AnalyticsService.logUpgradeMachine(machine.id, machine.level + 1);
      AppSnackbar.success('${machine.machine?.name ?? 'Machine'} upgraded!');
      await load();
      final updated = myMachines.firstWhereOrNull((m) => m.id == machine.id);
      if (updated != null) selected.value = updated;
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      upgradingId.value = null;
    }
  }
}

import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/farm/model/farm_model.dart';
import '../../../core/server_model/farm/model/farm_type_model.dart';
import '../../../core/server_model/farm/repository/farm_repository.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';

class FarmController extends GetxController {
  final FarmRepository _farmRepository = FarmRepository();
  final MachineRepository _machineRepository = MachineRepository();

  final isLoading = true.obs;
  final isUpgrading = false.obs;
  final farm = Rxn<FarmModel>();
  final farmTypes = <FarmTypeModel>[].obs;
  final myMachines = <UserMachineModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _farmRepository.myFarm(),
        _farmRepository.farmTypes(),
        _machineRepository.myMachines(),
      ]);
      farm.value = results[0] as FarmModel?;
      farmTypes.value = results[1] as List<FarmTypeModel>;
      myMachines.value = results[2] as List<UserMachineModel>;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> upgradeFarm() async {
    isUpgrading.value = true;
    try {
      await _farmRepository.upgradeFarm();
      AppSnackbar.success('Farm upgraded!');
      await load();
    } catch (e) {
      AppSnackbar.error(e.toString());
    } finally {
      isUpgrading.value = false;
    }
  }

  void goToMachines() => Get.toNamed(AppRoutes.machineList);
}

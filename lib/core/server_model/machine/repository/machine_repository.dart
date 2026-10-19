import '../model/machine_model.dart';
import '../model/user_machine_model.dart';
import '../service/machine_service.dart';

class MachineRepository {
  final MachineService _service = MachineService();

  Future<List<MachineModel>> catalog() => _service.fetchCatalog();

  Future<List<MachineModel>> storeMachines(String category) => _service.fetchStoreMachines(category);

  Future<void> rentWithCoins(String planId) => _service.rentWithCoins(planId);

  Future<List<UserMachineModel>> myMachines() => _service.fetchMyMachines();

  Future<void> upgrade(String userMachineId) => _service.upgradeMachine(userMachineId);
}

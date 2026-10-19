import '../model/farm_model.dart';
import '../model/farm_type_model.dart';
import '../service/farm_service.dart';

class FarmRepository {
  final FarmService _service = FarmService();

  Future<FarmModel?> myFarm() => _service.fetchMyFarm();

  Future<List<FarmTypeModel>> farmTypes() => _service.fetchFarmTypes();

  Future<void> upgradeFarm() => _service.upgradeFarm();

  Future<double> miningRate() => _service.fetchMiningRate();
}

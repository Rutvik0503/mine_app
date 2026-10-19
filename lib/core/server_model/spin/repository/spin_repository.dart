import '../model/spin_status_model.dart';
import '../service/spin_service.dart';

class SpinRepository {
  final SpinService _service = SpinService();

  Future<SpinStatusModel> status() => _service.fetchStatus();

  Future<SpinStatusModel> spinFree() => _service.spin('free');

  Future<SpinStatusModel> spinWithAd() => _service.spin('ad');
}

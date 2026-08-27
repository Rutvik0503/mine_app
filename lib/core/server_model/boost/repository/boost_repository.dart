import '../model/user_boost_model.dart';
import '../service/boost_service.dart';

class BoostRepository {
  final BoostService _service = BoostService();

  Future<List<UserBoostModel>> activeBoosts() => _service.fetchActiveBoosts();
}

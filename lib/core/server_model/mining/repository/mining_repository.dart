import '../model/mining_session_model.dart';
import '../service/mining_service.dart';

class MiningRepository {
  final MiningService _service = MiningService();

  Future<MiningSessionModel?> activeSession() => _service.fetchActiveSession();

  Future<List<MiningSessionModel>> history({int limit = 20}) => _service.fetchHistory(limit: limit);

  Future<void> startMining() => _service.startMining();

  Future<Map<String, dynamic>> claimMining(String sessionId) => _service.claimMining(sessionId);
}

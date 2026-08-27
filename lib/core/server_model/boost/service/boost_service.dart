import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/user_boost_model.dart';

class BoostService {
  final _client = SupabaseService.client;

  Future<List<UserBoostModel>> fetchActiveBoosts() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.userBoosts)
        .select('*, boosts(*)')
        .eq('user_id', userId)
        .eq('status', 'active');
    return rows.map((e) => UserBoostModel.fromJson(e)).toList();
  }
}

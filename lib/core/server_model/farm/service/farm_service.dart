import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/farm_model.dart';
import '../model/farm_type_model.dart';

class FarmService {
  final _client = SupabaseService.client;

  Future<FarmModel?> fetchMyFarm() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from(TableConstant.farms)
        .select('*, farm_types(*)')
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return FarmModel.fromJson(row);
  }

  Future<List<FarmTypeModel>> fetchFarmTypes() async {
    final rows = await _client
        .from(TableConstant.farmTypes)
        .select()
        .eq('is_active', true)
        .order('unlock_level');
    return rows.map((e) => FarmTypeModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> upgradeFarm() {
    return SupabaseService.invoke(ApiConstant.fnUpgradeFarm);
  }
}

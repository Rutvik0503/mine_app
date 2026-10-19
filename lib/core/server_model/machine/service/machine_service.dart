import '../../../constant/api_constant.dart';
import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/machine_model.dart';
import '../model/user_machine_model.dart';

class MachineService {
  final _client = SupabaseService.client;

  Future<List<MachineModel>> fetchCatalog() async {
    final rows = await _client.from(TableConstant.machines).select().eq('is_active', true);
    return rows.map((e) => MachineModel.fromJson(e)).toList();
  }

  /// Rentable miners for one farm category ('air' | 'hydro' | 'premium'),
  /// each with its plans, slowest first.
  Future<List<MachineModel>> fetchStoreMachines(String category) async {
    final rows = await _client
        .from(TableConstant.machines)
        .select('*, machine_plans(*)')
        .eq('is_active', true)
        .eq('farm_category', category)
        .order('base_hashrate', ascending: true);
    return rows.map((e) => MachineModel.fromJson(e)).toList();
  }

  /// Rents [planId] paid with coins - see supabase/functions/rent-machine.
  Future<Map<String, dynamic>> rentWithCoins(String planId) {
    return SupabaseService.invoke(ApiConstant.fnRentMachine, body: {'plan_id': planId});
  }

  Future<List<UserMachineModel>> fetchMyMachines() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.userMachines)
        .select('*, machines(*)')
        .eq('user_id', userId)
        .order('purchased_at');
    return rows.map((e) => UserMachineModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> upgradeMachine(String userMachineId) {
    return SupabaseService.invoke(
      ApiConstant.fnUpgradeMachine,
      body: {'user_machine_id': userMachineId},
    );
  }
}

import '../../../constant/table_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/purchase_model.dart';
import '../model/store_package_model.dart';

class StoreService {
  final _client = SupabaseService.client;

  /// Point packs shown on the Store screen - excludes session_extension
  /// packages, which are only ever offered contextually from the mining
  /// session-complete screen (see fetchSessionExtensionPackage below).
  Future<List<StorePackageModel>> fetchPackages() async {
    final rows = await _client
        .from(TableConstant.storePackages)
        .select()
        .eq('is_active', true)
        .eq('kind', 'points')
        .not('play_product_id', 'is', null)
        .order('price_cents');
    return rows.map((e) => StorePackageModel.fromJson(e)).toList();
  }

  Future<StorePackageModel?> fetchSessionExtensionPackage() async {
    final row = await _client
        .from(TableConstant.storePackages)
        .select()
        .eq('is_active', true)
        .eq('kind', 'session_extension')
        .order('price_cents')
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return StorePackageModel.fromJson(row);
  }

  Future<List<PurchaseModel>> fetchHistory() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from(TableConstant.purchases)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map((e) => PurchaseModel.fromJson(e)).toList();
  }
}

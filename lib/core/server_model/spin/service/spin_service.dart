import '../../../constant/api_constant.dart';
import '../../../services/supabase_service.dart';
import '../model/spin_status_model.dart';

class SpinService {
  Future<SpinStatusModel> fetchStatus() async {
    final res = await SupabaseService.invoke(ApiConstant.fnSpinWheel, body: {'action': 'status'});
    return SpinStatusModel.fromJson(res);
  }

  /// [source] is 'free' or 'ad'. The result is picked server-side.
  Future<SpinStatusModel> spin(String source) async {
    final res = await SupabaseService.invoke(
      ApiConstant.fnSpinWheel,
      body: {'action': 'spin', 'source': source},
    );
    return SpinStatusModel.fromJson(res);
  }
}

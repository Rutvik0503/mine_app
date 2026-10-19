import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/server_model/machine/model/machine_model.dart';
import '../../../core/server_model/machine/model/machine_plan_model.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/routes/app_routes.dart';
import 'farm_controller.dart';

/// Plan picker for one store miner. Opened with the [MachineModel] (plans
/// included) as `Get.arguments`.
class MachinePlanController extends GetxController {
  final MachineRepository _machineRepository = MachineRepository();
  final RewardRepository _rewardRepository = RewardRepository();

  late final MachineModel machine;
  final selected = Rxn<MachinePlanModel>();
  final coins = 0.0.obs;
  final isPayingCoins = false.obs;

  bool get isBusy => isPayingCoins.value;

  @override
  void onInit() {
    super.onInit();
    machine = Get.arguments as MachineModel;
    selected.value =
        machine.plans.firstWhereOrNull((p) => p.isPopular) ?? machine.plans.firstOrNull;
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      coins.value = await _rewardRepository.availableBalance();
    } catch (_) {
      // Coins button just stays disabled until a balance loads.
    }
  }

  void select(MachinePlanModel plan) {
    if (!isBusy) selected.value = plan;
  }

  bool get canAffordCoins {
    final plan = selected.value;
    return plan != null && coins.value >= plan.priceCoins;
  }

  /// Coins still missing for the selected plan (0 when affordable).
  double get coinShortfall {
    final plan = selected.value;
    if (plan == null) return 0;
    final missing = plan.priceCoins - coins.value;
    return missing > 0 ? missing.ceilToDouble() : 0;
  }

  /// Opens the coin Store, then refreshes the balance on return.
  Future<void> goToStore() async {
    await Get.toNamed(AppRoutes.store);
    await _loadCoins();
  }

  Future<void> payWithCoins() async {
    final plan = selected.value;
    if (plan == null || isBusy) return;
    isPayingCoins.value = true;
    try {
      await _machineRepository.rentWithCoins(plan.id);
      _onRented();
    } catch (e) {
      AppSnackbar.error(e.toString());
      await _loadCoins();
    } finally {
      isPayingCoins.value = false;
    }
  }

  void _onRented() {
    AppSnackbar.success('minerRented'.trParams({'name': machine.name}));
    _refreshFarm();
    Get.back();
  }

  void _refreshFarm() {
    if (Get.isRegistered<FarmController>()) Get.find<FarmController>().load();
  }
}

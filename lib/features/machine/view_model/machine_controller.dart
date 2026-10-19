import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/server_model/machine/model/user_machine_model.dart';
import '../../../core/server_model/machine/repository/machine_repository.dart';
import '../../../core/server_model/reward/repository/reward_repository.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/economy_formulas.dart';

class MachineController extends GetxController {
  final MachineRepository _machineRepository = MachineRepository();
  final RewardRepository _rewardRepository = RewardRepository();

  final isLoading = true.obs;
  final upgradingId = Rxn<String>();
  final myMachines = <UserMachineModel>[].obs;
  final selected = Rxn<UserMachineModel>();
  final availableBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _machineRepository.myMachines(),
        _rewardRepository.availableBalance(),
      ]);
      myMachines.value = results[0] as List<UserMachineModel>;
      availableBalance.value = results[1] as double;
    } finally {
      isLoading.value = false;
    }
  }

  void openDetail(UserMachineModel machine) {
    selected.value = machine;
    Get.toNamed(AppRoutes.machineDetail);
  }

  int upgradeCost(UserMachineModel machine) => EconomyFormulas.machineUpgradeCost(machine.level + 1);

  /// Machine upgrades cost coins; short on coins, the dialog offers the
  /// Store (coin packs via Google Play).
  Future<void> onUpgradeTap(UserMachineModel machine) async {
    if (upgradingId.value != null) return;
    final cost = upgradeCost(machine);
    final balance = availableBalance.value;
    final canAfford = balance >= cost;
    final nextLevel = machine.level + 1;

    final choice = await Get.dialog<String>(
      AlertDialog(
        title: Text('upgradeToLevel'.trParams({'level': '$nextLevel'})),
        content: Text(
          canAfford
              ? 'upgradeConfirmBody'.trParams({
                  'cost': '$cost',
                  'before': balance.toStringAsFixed(0),
                  'after': (balance - cost).toStringAsFixed(0),
                })
              : 'notEnoughPointsBody'.trParams({
                  'level': '$nextLevel',
                  'cost': '$cost',
                  'balance': balance.toStringAsFixed(0),
                  'shortfall': (cost - balance).toStringAsFixed(0),
                }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          if (canAfford)
            ElevatedButton(
              onPressed: () => Get.back(result: 'coins'),
              child: Text('payWithPoints'.trParams({'cost': '$cost'})),
            )
          else
            ElevatedButton(
              onPressed: () => Get.back(result: 'store'),
              child: Text('Get coins'.tr),
            ),
        ],
      ),
    );

    if (choice == 'coins') {
      await upgrade(machine);
    } else if (choice == 'store') {
      await Get.toNamed(AppRoutes.store);
      await load();
    }
  }

  Future<void> upgrade(UserMachineModel machine) async {
    upgradingId.value = machine.id;
    try {
      await _machineRepository.upgrade(machine.id);
      await AnalyticsService.logUpgradeMachine(machine.id, machine.level + 1);
      AppSnackbar.success('machineUpgraded'.trParams({'name': machine.machine?.name ?? 'Machine'}));
      await _reloadSelected(machine.id);
    } catch (e) {
      debugPrint('Upgrade machine failed: $e');
      AppSnackbar.error(e.toString());
    } finally {
      upgradingId.value = null;
    }
  }

  Future<void> _reloadSelected(String id) async {
    await load();
    final updated = myMachines.firstWhereOrNull((m) => m.id == id);
    if (updated != null) selected.value = updated;
  }
}

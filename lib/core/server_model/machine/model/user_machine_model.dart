import 'machine_model.dart';

class UserMachineModel {
  final String id;
  final String userId;
  final String farmId;
  final String machineId;
  final int level;
  final double currentHashrate;
  final double currentEfficiency;
  final String status;
  final DateTime purchasedAt;
  final MachineModel? machine;

  UserMachineModel({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.machineId,
    required this.level,
    required this.currentHashrate,
    required this.currentEfficiency,
    required this.status,
    required this.purchasedAt,
    this.machine,
  });

  factory UserMachineModel.fromJson(Map<String, dynamic> json) => UserMachineModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        farmId: json['farm_id'] as String,
        machineId: json['machine_id'] as String,
        level: (json['level'] as num?)?.toInt() ?? 1,
        currentHashrate: (json['current_hashrate'] as num?)?.toDouble() ?? 0,
        currentEfficiency: (json['current_efficiency'] as num?)?.toDouble() ?? 0.8,
        status: json['status'] as String? ?? 'active',
        purchasedAt: DateTime.tryParse(json['purchased_at'] ?? '') ?? DateTime.now(),
        machine: json['machines'] != null
            ? MachineModel.fromJson(Map<String, dynamic>.from(json['machines']))
            : null,
      );
}

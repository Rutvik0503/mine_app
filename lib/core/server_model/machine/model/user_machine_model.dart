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
  /// Set for rented store miners; null for owned/starter machines.
  final DateTime? expiresAt;
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
    this.expiresAt,
    this.machine,
  });

  bool get isRental => expiresAt != null;
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// A running rental with a day or less left - shown in warning colour.
  bool get endsSoon =>
      isRental && !isExpired && expiresAt!.difference(DateTime.now()) <= const Duration(days: 1);

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
        expiresAt: DateTime.tryParse(json['expires_at'] ?? ''),
        machine: json['machines'] != null
            ? MachineModel.fromJson(Map<String, dynamic>.from(json['machines']))
            : null,
      );
}

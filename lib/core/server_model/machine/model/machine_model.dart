import 'machine_plan_model.dart';

class MachineModel {
  final String id;
  final String name;
  final String machineType;
  final double baseHashrate;
  final double baseEfficiency;
  final int maxLevel;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  /// 'air' | 'hydro' | 'premium' for rentable store miners, null otherwise.
  final String? farmCategory;
  final int? powerWatts;
  final List<MachinePlanModel> plans;

  MachineModel({
    required this.id,
    required this.name,
    required this.machineType,
    required this.baseHashrate,
    required this.baseEfficiency,
    required this.maxLevel,
    this.imageUrl,
    this.description,
    required this.isActive,
    this.farmCategory,
    this.powerWatts,
    this.plans = const [],
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
        id: json['id'] as String,
        name: json['name'] as String,
        machineType: json['machine_type'] as String? ?? 'standard',
        baseHashrate: (json['base_hashrate'] as num?)?.toDouble() ?? 0,
        baseEfficiency: (json['base_efficiency'] as num?)?.toDouble() ?? 0.8,
        maxLevel: (json['max_level'] as num?)?.toInt() ?? 10,
        imageUrl: json['image_url'] as String?,
        description: json['description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        farmCategory: json['farm_category'] as String?,
        powerWatts: (json['power_watts'] as num?)?.toInt(),
        plans: ((json['machine_plans'] as List?) ?? [])
            .map((e) => MachinePlanModel.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.isActive)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      );
}

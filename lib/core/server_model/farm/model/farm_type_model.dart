class FarmTypeModel {
  final String id;
  final String name;
  final String? description;
  final double baseMultiplier;
  final int machineCapacity;
  final int unlockLevel;
  final bool isActive;

  FarmTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.baseMultiplier,
    required this.machineCapacity,
    required this.unlockLevel,
    required this.isActive,
  });

  factory FarmTypeModel.fromJson(Map<String, dynamic> json) => FarmTypeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        baseMultiplier: (json['base_multiplier'] as num?)?.toDouble() ?? 1.0,
        machineCapacity: (json['machine_capacity'] as num?)?.toInt() ?? 1,
        unlockLevel: (json['unlock_level'] as num?)?.toInt() ?? 1,
        isActive: json['is_active'] as bool? ?? true,
      );
}

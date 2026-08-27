class MachineModel {
  final String id;
  final String name;
  final String machineType;
  final double baseHashrate;
  final double baseEfficiency;
  final int maxLevel;
  final String? imageUrl;
  final bool isActive;

  MachineModel({
    required this.id,
    required this.name,
    required this.machineType,
    required this.baseHashrate,
    required this.baseEfficiency,
    required this.maxLevel,
    this.imageUrl,
    required this.isActive,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
        id: json['id'] as String,
        name: json['name'] as String,
        machineType: json['machine_type'] as String? ?? 'standard',
        baseHashrate: (json['base_hashrate'] as num?)?.toDouble() ?? 0,
        baseEfficiency: (json['base_efficiency'] as num?)?.toDouble() ?? 0.8,
        maxLevel: (json['max_level'] as num?)?.toInt() ?? 10,
        imageUrl: json['image_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}

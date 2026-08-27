import 'farm_type_model.dart';

class FarmModel {
  final String id;
  final String userId;
  final String farmTypeId;
  final String name;
  final int level;
  final int capacity;
  final double multiplier;
  final FarmTypeModel? farmType;

  FarmModel({
    required this.id,
    required this.userId,
    required this.farmTypeId,
    required this.name,
    required this.level,
    required this.capacity,
    required this.multiplier,
    this.farmType,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        farmTypeId: json['farm_type_id'] as String,
        name: json['name'] as String? ?? 'My Farm',
        level: (json['level'] as num?)?.toInt() ?? 1,
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
        farmType: json['farm_types'] != null
            ? FarmTypeModel.fromJson(Map<String, dynamic>.from(json['farm_types']))
            : null,
      );
}

class BoostModel {
  final String id;
  final String name;
  final String type;
  final double multiplier;
  final int durationMinutes;
  final String source;
  final bool isActive;

  BoostModel({
    required this.id,
    required this.name,
    required this.type,
    required this.multiplier,
    required this.durationMinutes,
    required this.source,
    required this.isActive,
  });

  factory BoostModel.fromJson(Map<String, dynamic> json) => BoostModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'mining',
        multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
        source: json['source'] as String? ?? 'ad',
        isActive: json['is_active'] as bool? ?? true,
      );
}

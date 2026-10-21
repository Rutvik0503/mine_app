class MachinePlanModel {
  final String id;
  final String machineId;
  final String label;
  final int durationDays;
  final int pricePaise;
  final double priceCoins;
  final bool isPopular;
  final int sortOrder;
  final bool isActive;

  MachinePlanModel({
    required this.id,
    required this.machineId,
    required this.label,
    required this.durationDays,
    required this.pricePaise,
    required this.priceCoins,
    required this.isPopular,
    required this.sortOrder,
    required this.isActive,
  });


  factory MachinePlanModel.fromJson(Map<String, dynamic> json) => MachinePlanModel(
        id: json['id'] as String,
        machineId: json['machine_id'] as String,
        label: json['label'] as String,
        durationDays: (json['duration_days'] as num).toInt(),
        pricePaise: (json['price_paise'] as num).toInt(),
        priceCoins: (json['price_coins'] as num).toDouble(),
        isPopular: json['is_popular'] as bool? ?? false,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );
}

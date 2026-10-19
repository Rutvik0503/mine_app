class StorePackageModel {
  final String id;
  final String name;
  final String? description;
  final double points;
  final int priceCents;
  final String currency;
  final String kind; // points | session_extension
  final int? extensionMinutes;

  /// Matching Google Play Console in-app product id (e.g. coins_200).
  final String? playProductId;

  StorePackageModel({
    required this.id,
    required this.name,
    this.description,
    required this.points,
    required this.priceCents,
    required this.currency,
    this.kind = 'points',
    this.extensionMinutes,
    this.playProductId,
  });

  bool get isSessionExtension => kind == 'session_extension';

  /// Fallback price label; the Store prefers Play's localized price.
  String get priceLabel => currency.toLowerCase() == 'inr'
      ? '₹${(priceCents / 100).toStringAsFixed(0)}'
      : '${(priceCents / 100).toStringAsFixed(2)} ${currency.toUpperCase()}';

  factory StorePackageModel.fromJson(Map<String, dynamic> json) => StorePackageModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        points: (json['points'] as num?)?.toDouble() ?? 0,
        priceCents: (json['price_cents'] as num?)?.toInt() ?? 0,
        currency: json['currency'] as String? ?? 'inr',
        kind: json['kind'] as String? ?? 'points',
        extensionMinutes: (json['extension_minutes'] as num?)?.toInt(),
        playProductId: json['play_product_id'] as String?,
      );
}

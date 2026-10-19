class PurchaseModel {
  final String id;
  final String userId;
  final String? packageId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final int amountCents;
  final String currency;
  final double pointsGranted;
  final String status; // pending | succeeded | failed | refunded
  final DateTime createdAt;

  PurchaseModel({
    required this.id,
    required this.userId,
    this.packageId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    required this.amountCents,
    required this.currency,
    required this.pointsGranted,
    required this.status,
    required this.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        packageId: json['package_id'] as String?,
        razorpayOrderId: json['razorpay_order_id'] as String?,
        razorpayPaymentId: json['razorpay_payment_id'] as String?,
        amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
        currency: json['currency'] as String? ?? 'inr',
        pointsGranted: (json['points_granted'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );
}

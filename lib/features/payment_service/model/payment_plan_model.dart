class PaymentPlanModel {
  final String id;
  final String stripeProductId;
  final String stripePriceId;
  final String name;
  final String description;
  final String plan;
  final int amountCents;
  final String currency;
  final String intervalUnit;
  final int intervalCount;
  final bool isActive;

  const PaymentPlanModel({
    required this.id,
    required this.stripeProductId,
    required this.stripePriceId,
    required this.name,
    required this.description,
    required this.plan,
    required this.amountCents,
    required this.currency,
    required this.intervalUnit,
    required this.intervalCount,
    required this.isActive,
  });

  factory PaymentPlanModel.fromJson(Map<String, dynamic> json) {
    return PaymentPlanModel(
      id: json['id'] as String? ?? '',
      stripeProductId: json['stripeProductId'] as String? ?? '',
      stripePriceId: json['stripePriceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      amountCents: json['amountCents'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'usd',
      intervalUnit: json['intervalUnit'] as String? ?? '',
      intervalCount: json['intervalCount'] as int? ?? 1,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  String get displayPrice {
    final amount = amountCents / 100;
    final amountText = amount == amount.truncateToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    final intervalText = intervalCount <= 1
        ? intervalUnit
        : '$intervalCount $intervalUnit';
    return '${currency.toUpperCase()} $amountText/$intervalText';
  }
}

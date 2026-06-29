import 'package:flutter/widgets.dart';

class SubscriptionPlanModel2 {
  final String name;
  final String price;
  final String period;
  final String subtext;
  final bool isPro;
  final String badgeText;

  const SubscriptionPlanModel2({
    required this.name,
    required this.price,
    required this.period,
    required this.subtext,
    this.isPro = false,
    this.badgeText = '',
  });
}

class SubscriptionFeatureRow {
  final String featureName;
  final SubscriptionFeatureValue freeValue;
  final SubscriptionFeatureValue proValue;

  const SubscriptionFeatureRow({
    required this.featureName,
    required this.freeValue,
    required this.proValue,
  });
}

class SubscriptionFeatureValue {
  final String text;
  final String? subtext;
  final String? assetPath;
  final IconData? iconData;

  const SubscriptionFeatureValue({
    required this.text,
    this.subtext,
    this.assetPath,
    this.iconData,
  });
}
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/profile_and_setting/model/subscription_plan_model.dart';

class SubscriptionPlanController extends GetxController {
  final freePlan = const SubscriptionPlanModel2(
    name: 'FREE PLAN',
    price: '\$0',
    period: '',
    subtext: 'Forever',
    isPro: false,
  );

  final proPlan = const SubscriptionPlanModel2(
    name: 'PRO PLAN',
    price: '\$9.99',
    period: ' / month',
    subtext: 'Cancel anytime',
    isPro: true,
    badgeText: 'BEST VALUE',
  );

  late final List<SubscriptionFeatureRow> features = [
    SubscriptionFeatureRow(
      featureName: 'Submit Fishing Reports',
      freeValue: SubscriptionFeatureValue(
        text: 'Included',
        assetPath: IconPath.fishIcon,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'Included',
        assetPath: IconPath.fishIcon,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Public Reports',
      freeValue: SubscriptionFeatureValue(
        text: '72-hour delay',
        iconData: Icons.hourglass_empty,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'Real-time',
        iconData: Icons.bolt,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Heatmap',
      freeValue: SubscriptionFeatureValue(
        text: 'Delayed',
        assetPath: IconPath.waveIcon,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'Live',
        assetPath: IconPath.waveIcon,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Report History',
      freeValue: SubscriptionFeatureValue(
        text: 'Last 72 hours',
        subtext: '(72-hour delay)',
        iconData: Icons.hourglass_empty,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'Unlimited history',
        subtext: '(Real-time access)',
        iconData: Icons.anchor,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Groups',
      freeValue: SubscriptionFeatureValue(
        text: 'Join existing',
        subtext: '(Cannot create)',
        iconData: Icons.person_outline,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'Create & manage groups',
        iconData: Icons.people_outline,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Weather Forecast',
      freeValue: SubscriptionFeatureValue(
        text: 'Current + 2-day forecast',
        iconData: Icons.wb_cloudy_outlined,
      ),
      proValue: SubscriptionFeatureValue(
        text: '5-day extended forecast',
        iconData: Icons.wb_sunny_outlined,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Notifications',
      freeValue: SubscriptionFeatureValue(
        text: 'System only',
        subtext: '(Account, password, announcements)',
        iconData: Icons.flag_outlined,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'All fishing notifications',
        subtext: 'Hot bites, new reports, group messages',
        iconData: Icons.notifications_none,
      ),
    ),
    SubscriptionFeatureRow(
      featureName: 'Future Premium Features',
      freeValue: SubscriptionFeatureValue(
        text: 'Not included',
        iconData: Icons.horizontal_rule,
      ),
      proValue: SubscriptionFeatureValue(
        text: 'Included',
        iconData: Icons.star_border,
      ),
    ),
  ];
}
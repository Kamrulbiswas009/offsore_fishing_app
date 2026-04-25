import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/settings_screen.dart';

class ProfileMainScreenController extends GetxController {
  final String profileName = 'Captain Mike';
  final String email = 'captain.mike@example.com';
  final String profileImagePath = ImagePath.messageProfileImage;

  late final List<ProfileStatModel> stats = <ProfileStatModel>[
    ProfileStatModel(
      value: '127',
      label: 'Reports Submitted',
      iconPath: IconPath.fishIcon,
      borderColor: AppColors.tealColor117A88.withValues(alpha: 0.15),
      iconBackgroundColor: AppColors.teal163A42Color,
    ),
    ProfileStatModel(
      value: '18',
      label: 'Zones Active',
      iconPath: IconPath.locationIcon,
      borderColor: AppColors.orangeFF6B35Color.withValues(alpha: 0.30),
      iconBackgroundColor: AppColors.orange3F2B27Color,
    ),
    ProfileStatModel(
      value: '42',
      label: 'Pattern Matches',
      iconPath: IconPath.curveArrowIcon,
      borderColor: AppColors.tealColor117A88,
      iconBackgroundColor: AppColors.green10B981Color.withValues(alpha: 0.15),
    ),
  ];

  late final SubscriptionPlanModel subscriptionPlan =
      const SubscriptionPlanModel(
        title: 'Free Plan',
        price: '\$0',
        description: 'Basic features with delayed data',
        features: <String>[
          'Delayed heatmap (6-24h)',
          'Limited report access',
          'Basic notifications',
          'Standard analytics',
        ],
      );

  void onNotificationsTap() {}

  void onEditProfile() {}

  void onUpgradeToPro() {}

  void onLogout() {}

  void openSettings() {
    Get.to(() => SettingsScreen());
  }
}

class ProfileStatModel {
  final String value;
  final String label;
  final String iconPath;
  final Color borderColor;
  final Color iconBackgroundColor;

  const ProfileStatModel({
    required this.value,
    required this.label,
    required this.iconPath,
    required this.borderColor,
    required this.iconBackgroundColor,
  });
}

class SubscriptionPlanModel {
  final String title;
  final String price;
  final String description;
  final List<String> features;

  const SubscriptionPlanModel({
    required this.title,
    required this.price,
    required this.description,
    required this.features,
  });
}

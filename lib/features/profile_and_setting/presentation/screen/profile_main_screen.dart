import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/profile_info_card_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/profile_stat_card_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/subscription_plan_card_widget.dart';

class ProfileMainScreen extends StatelessWidget {
  final ProfileMainScreenController controller =
      Get.find<ProfileMainScreenController>();

  ProfileMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // CustomBackButton(ontap: Get.back),
                  Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 16,
                      ),
                    ),
                  ),
                  CustomBackButton(
                    ontap: controller.onNotificationsTap,
                    icon: Image.asset(
                      IconPath.notificationIcon,
                      width: 20.r,
                      height: 20.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  CustomBackButton(
                    ontap: controller.openSettings,
                    icon: Image.asset(
                      IconPath.settingIcon,
                      width: 20.r,
                      height: 20.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26.h),
              ProfileInfoCardWidget(
                name: controller.profileName,
                email: controller.email,
                imagePath: controller.profileImagePath,
                onEditTap: controller.onEditProfile,
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  for (
                    int index = 0;
                    index < controller.stats.length;
                    index++
                  ) ...[
                    Expanded(
                      child: ProfileStatCardWidget(
                        item: controller.stats[index],
                      ),
                    ),
                    if (index != controller.stats.length - 1)
                      SizedBox(width: 12.w),
                  ],
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Subscription',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
              SizedBox(height: 14.h),
              SubscriptionPlanCardWidget(
                plan: controller.subscriptionPlan,
                onUpgradeTap: controller.onUpgradeToPro,
              ),
              SizedBox(height: 28.h),
              CustomButton(
                ontap: controller.onLogout,
                title: 'Logout',
                bgColor: Color(0xFFFB2C36).withValues(alpha: 0.1),
                borderColor: AppColors.redDA605CColor.withValues(alpha: 0.1),
                titleColor: AppColors.redDA605CColor,
                borderRadius: 16.r,
                //padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Image.asset(
                    IconPath.logoutIcon,
                    width: 20.r,
                    height: 20.r,
                    color: AppColors.redDA605CColor,
                  ),
                ),
              ),
              SizedBox(height: 70.h),
            ],
          ),
        ),
      ),
    );
  }
}

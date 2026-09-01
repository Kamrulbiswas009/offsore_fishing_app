import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/device/device_utility.dart';
import 'package:paytonpieper/features/notification/controller/notification_screen_controller.dart';
import 'package:paytonpieper/features/payment_service/controller/payment_service_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/profile_info_card_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/profile_stat_card_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/subscription_plan_widget.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class ProfileMainScreen extends StatelessWidget {
  final ProfileMainScreenController controller =
      Get.find<ProfileMainScreenController>();

  final PaymentServiceController paymentServiceController =
      Get.find<PaymentServiceController>();

  final NotificationScreenController notificationController =
      Get.find<NotificationScreenController>();

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
                    icon: Obx(
                      () => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            IconPath.notificationIcon,
                            width: 20.r,
                            height: 20.r,
                          ),
                          if (notificationController.unreadCount > 0)
                            Positioned(
                              top: -8.h,
                              right: -8.w,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 16.r),
                                height: 16.r,
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.orangeFF6B35Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  notificationController.unreadCount > 99
                                      ? '99+'
                                      : '${notificationController.unreadCount}',
                                  style: getTextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.whiteColor,
                                    lineHeight: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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
              Obx(
                () => ProfileInfoCardWidget(
                  isPremiumAccount: controller.isPremiumAccount,
                  name: controller.profileName,
                  email: controller.email,
                  imagePath: controller.profileImagePath,
                  onEditTap: controller.onEditProfile,
                  cancelAtPeriodEnd: controller.cancelAtPeriodEnd,
                  currentPeriodEnd: controller.currentPeriodEnd,
                ),
              ),
              SizedBox(height: 22.h),
              Obx(
                () => IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                ),
              ),
              SizedBox(height: 24.h),
              CustomButton(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                fontSize: 16,
                lineHeight: 12,
                ontap: () => Get.toNamed(AppRoute.watchedZonesScreen),
                title: 'Bite Watch Alerts',
                bgColor: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                borderColor: const Color(0xFFFF6D00).withValues(alpha: 0.2),
                titleColor: const Color(0xFFFF6D00),
                borderRadius: 16.r,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: Color(0xFFFF6D00),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Subscription',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
              Text(
                'Compare features and choose the plan that fits your fishing.',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyC8D0DBColor,
                  lineHeight: 9,
                ),
              ),

              SizedBox(height: 14.h),
              SubscriptionPlanWidget(),
              SizedBox(height: 12.h),
              Obx(() {
                if (!controller.isPremiumAccount) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    controller.cancelAtPeriodEnd
                        ? "You have canceled subscription, Do you want to renew it"
                        : "You are already a pro member. Do you want to cancel it.",
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyC8D0DBColor,
                      lineHeight: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              Obx(() {
                if (!controller.isPremiumAccount) {
                  return CustomButton(
                    ontap: () => paymentServiceController.openUnlockProFlow(),
                    title: "Unlock Pro >",
                    lineHeight: 14,
                    fontSize: 16,
                    bgColor: AppColors.orangeColor,
                  );
                } else if (controller.cancelAtPeriodEnd) {
                  return CustomButton(
                    ontap: () => paymentServiceController
                        .showReactivateSubscriptionDialog(),
                    title: "Re-Active Pro",
                    lineHeight: 14,
                    fontSize: 16,
                    bgColor: AppColors.orangeColor,
                  );
                } else {
                  return CustomButton(
                    ontap: () =>
                        paymentServiceController.showCancelSubscriptionDialog(),
                    title: "Cancel Subscription",
                    lineHeight: 14,
                    fontSize: 16,
                    bgColor: const Color(0xFFFB2C36),
                  );
                }
              }),
              SizedBox(height: 4.h),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "• Secure payments powered by Stripe. Your payment information is never stored by us. Before Subscription read our ",
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyC8D0DBColor,
                      lineHeight: 11,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppDeviceUtility.launchUrl(
                        'https://docs.google.com/presentation/d/1yxnsA-50zWnUfibbG7Rc7ajzKwknOnR5k58aybXy6OE/edit?usp=sharing',
                      );
                    },
                    child: Text(
                      "Privacy Policy.",
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blue00D4FFColor,
                        lineHeight: 11,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),
              CustomButton(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                fontSize: 16,
                lineHeight: 12,
                ontap: controller.onLogout,
                title: 'Log Out',
                bgColor: Color(0xFFFB2C36).withValues(alpha: 0.1),
                borderColor: AppColors.redDA605CColor.withValues(alpha: 0.1),
                titleColor: Color(0xFFFF6467),
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

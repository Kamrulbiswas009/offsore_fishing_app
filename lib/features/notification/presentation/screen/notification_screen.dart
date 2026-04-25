import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/notification/controller/notification_screen_controller.dart';
import 'package:paytonpieper/features/notification/presentation/widget/notification_screen_widget/notification_item_widget.dart';
import 'package:paytonpieper/features/notification/presentation/widget/notification_screen_widget/notification_pro_banner_widget.dart';
import 'package:paytonpieper/features/notification/presentation/widget/notification_screen_widget/notification_tab_bar_widget.dart';

class NotificationScreen extends GetView<NotificationScreenController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CustomBackButton(ontap: Get.back),
                  Expanded(
                    child: Text(
                      'Notification',
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
              SizedBox(height: 26.h),
              const NotificationTabBarWidget(),
              SizedBox(height: 22.h),
              const NotificationProBannerWidget(),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  final notifications = controller.filteredNotifications;

                  return ListView.builder(
                    itemCount: notifications.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return NotificationItemWidget(
                        item: notifications[index],
                        showDivider: index != notifications.length - 1,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

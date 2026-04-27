import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/notification/controller/notification_screen_controller.dart';

class NotificationTabBarWidget extends GetView<NotificationScreenController> {
  const NotificationTabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: NotificationTab.values.map((tab) {
          final bool isSelected = controller.selectedTab.value == tab;
          final bool showBadge = tab == NotificationTab.unread;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(tab),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                //height: 46.h,
                margin: EdgeInsets.only(
                  right: tab == NotificationTab.all ? 7.w : 0,
                  left: tab == NotificationTab.unread ? 7.w : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: <Color>[
                            AppColors.tealColor117A88,
                            AppColors.blue00D4FFColor.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.transparentColor,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.blue00F0FFColor.withValues(alpha: 0.3)
                        : AppColors.grey516173Color,
                  ),
                  boxShadow: isSelected
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.blue00D4FFColor.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 16.r,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _label(tab),
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColor,
                        lineHeight: 10,
                      ),
                    ),
                    if (showBadge) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 18.r,
                        height: 18.r,
                        decoration: const BoxDecoration(
                          color: AppColors.orangeFF6B35Color,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${controller.unreadCount}',
                          style: getTextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whiteColor,
                            lineHeight: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(NotificationTab tab) => switch (tab) {
    NotificationTab.all => 'All',
    NotificationTab.unread => 'Unread',
  };
}

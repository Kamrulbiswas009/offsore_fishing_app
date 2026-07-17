import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/main_screen/controller/main_screen_controller.dart';
import 'package:paytonpieper/features/notification/controller/notification_screen_controller.dart';
import 'package:paytonpieper/features/notification/presentation/widget/notification_screen_widget/notification_item_widget.dart';
import 'package:paytonpieper/features/notification/presentation/widget/notification_screen_widget/notification_pro_banner_widget.dart';
import 'package:paytonpieper/features/notification/presentation/widget/notification_screen_widget/notification_tab_bar_widget.dart';
import 'package:paytonpieper/routes/app_routes.dart';
import 'package:paytonpieper/features/map/controller/map_screen_controller.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';

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
                      'Notifications',
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
                    controller: controller.scrollController,
                    itemCount: notifications.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return NotificationItemWidget(
                        item: notifications[index],
                        onTap: () =>
                            _handleNotificationTap(notifications[index]),
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

  void _handleNotificationTap(NotificationItemModel item) {
    controller.markAsRead(item);
    
    if (item.isGroupMessage) {
      Get.find<MainScreenController>().changeIndex(2);
      Get.offNamed(
        AppRoute.getGroupDetailsScreen(),
        arguments: <String, dynamic>{
          'groupId': item.groupId,
          'groupName': item.groupName,
          'initialTab': 'chat',
        },
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute == AppRoute.getGroupDetailsScreen()) {
          Get.find<GroupDetailsScreenController>().fetchGroupDetails(
            item.groupId,
          );
        }
      });
      return;
    }

    final zoneId = item.zoneId.isNotEmpty ? item.zoneId : _parseZoneIdFromDeepLink(item.deepLink);
    if (zoneId.isNotEmpty) {
      if (Get.currentRoute != AppRoute.homeMainScreen) {
        Get.until((route) => Get.currentRoute == AppRoute.homeMainScreen);
      }
      
      Get.find<MainScreenController>().changeIndex(0);
      
      try {
        final mapCtrl = Get.find<MapScreenController>();
        mapCtrl.selectZoneById(zoneId);
      } catch (e) {
        AppLoggerHelper.error('Could not select zone by ID: $zoneId', e);
      }
    }
  }

  String _parseZoneIdFromDeepLink(String deepLink) {
    if (deepLink.isEmpty) return '';
    try {
      final uri = Uri.parse(deepLink);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}
    return '';
  }
}

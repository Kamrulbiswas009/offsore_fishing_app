import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class NotificationScreenController extends GetxController {
  final Rx<NotificationTab> selectedTab = NotificationTab.all.obs;

  late final List<NotificationItemModel> notifications =
      <NotificationItemModel>[
        NotificationItemModel(
          title: 'Hot Zone Alert',
          description:
              'GOM-A12 showing high activity - 15 reports in last 2 hours',
          time: '5 min ago',
          isUnread: true,
          icon: Icons.local_fire_department_outlined,
          iconColor: AppColors.orangeFF6B35Color,
          iconBackgroundColor: AppColors.maroon271B2CColor,
        ),
        NotificationItemModel(
          title: 'New Group Report',
          description: 'Captain Mike caught 3 Tuna in Gulf Coast Crew',
          time: '1 hour ago',
          isUnread: true,
          icon: Icons.group_outlined,
          iconColor: AppColors.blue00D4FFColor,
          iconBackgroundColor: AppColors.blue0D2B43Color,
        ),
        NotificationItemModel(
          title: 'Trending Pattern',
          description: 'Trolling with Ballyhoo showing 85% success rate',
          time: '3 hours ago',
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.green10B981Color,
          iconBackgroundColor: AppColors.green183C39Color,
        ),
        NotificationItemModel(
          title: 'Weather Alert',
          description: 'Favorable conditions expected in GOM-B13 tomorrow',
          time: '5 hours ago',
          icon: Icons.notifications_none_rounded,
          iconColor: AppColors.whiteE5E7EBColor,
          iconBackgroundColor: AppColors.blue1B2134Color,
        ),
        NotificationItemModel(
          title: 'New Member',
          description: 'Sarah Johnson joined Gulf Coast Crew',
          time: '1 day ago',
          icon: Icons.group_outlined,
          iconColor: AppColors.blue00D4FFColor,
          iconBackgroundColor: AppColors.blue0D2B43Color,
        ),
      ];

  void changeTab(NotificationTab tab) {
    selectedTab.value = tab;
  }

  List<NotificationItemModel> get filteredNotifications {
    if (selectedTab.value == NotificationTab.unread) {
      return notifications.where((item) => item.isUnread).toList();
    }
    return notifications;
  }

  int get unreadCount => notifications.where((item) => item.isUnread).length;
}

enum NotificationTab { all, unread }

class NotificationItemModel {
  final String title;
  final String description;
  final String time;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const NotificationItemModel({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.isUnread = false,
  });
}

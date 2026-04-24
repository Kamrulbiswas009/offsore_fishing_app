import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';

class GroupDetailsTabBar extends GetView<GroupDetailsScreenController> {
  const GroupDetailsTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.black0F1E33Color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey3A4B62Color),
      ),
      child: Row(
        children: GroupDetailsTab.values
            .map((tab) => Expanded(child: _TabItem(tab: tab)))
            .toList(),
      ),
    );
  }
}

class _TabItem extends GetView<GroupDetailsScreenController> {
  final GroupDetailsTab tab;

  const _TabItem({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == tab;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: CustomButton(
          ontap: () => controller.changeTab(tab),
          title: _title,
          fontSize: 14,
          lineHeight: 10,
          borderRadius: 10,
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 7.h),
          bgColor: isSelected
              ? AppColors.orangeFF6B35Color
              : AppColors.transparentColor,
          titleColor: isSelected
              ? AppColors.whiteColor
              : AppColors.grey8B95A5Color,
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: Image.asset(
              _iconPath,
              width: 15.r,
              height: 15.r,
              color: isSelected
                  ? AppColors.whiteColor
                  : AppColors.grey8B95A5Color,
            ),
          ),
        ),
      );
    });
  }

  String get _title => switch (tab) {
    GroupDetailsTab.reports => 'Reports',
    GroupDetailsTab.chat => 'Chat',
    GroupDetailsTab.members => 'Members',
  };

  String get _iconPath => switch (tab) {
    GroupDetailsTab.reports => IconPath.reportIcon,
    GroupDetailsTab.chat => IconPath.chatIcon,
    GroupDetailsTab.members => IconPath.doublePersonWhiteIcon,
  };
}

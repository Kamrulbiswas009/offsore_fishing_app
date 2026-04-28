import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

import '../controller/main_screen_controller.dart';

class CustomBottomNavBar extends GetView<MainScreenController> {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.blue153A56Color, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _navItem(0, IconPath.map, "Map")),
          Expanded(child: _navItem(1, IconPath.report, "Report")),
          Expanded(child: _navItem(2, IconPath.groups, "Groups")),
          Expanded(child: _navItem(3, IconPath.profile, "Profile")),
        ],
      ),
    );
  }

  Widget _navItem(int index, String icon, String label) {
    return Obx(() {
      bool isSelected = controller.currentIndex.value == index;
      Color activeColor = AppColors.blue00F0FFColor;
      Color inactiveColor = AppColors.grey8B95A5Color;

      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              height: 25.h,
              width: 25.w,
              color: isSelected ? activeColor : inactiveColor,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: getTextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}

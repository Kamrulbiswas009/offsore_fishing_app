import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

import '../controller/main_screen_controller.dart';

class CustomBottomNavBar extends GetView<MainScreenController> {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 25.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.blue1B2134Color,
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(color: AppColors.blue153A56Color, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.map_outlined, "Map"),
          _navItem(1, Icons.edit_note_rounded, "Report"),
          _navItem(2, Icons.group_outlined, "Groups"),
          _navItem(3, Icons.person_outline_rounded, "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
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
            Icon(
              icon,
              size: 26.sp,
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
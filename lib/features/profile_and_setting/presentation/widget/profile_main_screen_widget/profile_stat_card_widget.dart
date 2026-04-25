import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';

class ProfileStatCardWidget extends StatelessWidget {
  final ProfileStatModel item;

  const ProfileStatCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.black2A2F3AColor.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: item.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.iconBackgroundColor,
            ),
            child: Image.asset(item.iconPath,height: 18.r,width: 18.r,),
          ),
          SizedBox(height: 8.h),
          Text(
            item.value,
            style: getTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
              lineHeight: 14,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.grey8B95A5Color,
              lineHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class SettingsActionTileWidget extends StatelessWidget {
  final String title;
  final String leadingIcon;
  final VoidCallback onTap;

  const SettingsActionTileWidget({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.black2A2F3AColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Image.asset(leadingIcon, color: AppColors.tealColor117A88, height: 18.r,width: 18.r,),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey8B95A5Color,
              size: 22.r,
            ),
          ],
        ),
      ),
    );
  }
}

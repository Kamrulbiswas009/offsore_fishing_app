import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class SettingsSectionHeaderWidget extends StatelessWidget {
  final String title;
  final String iconPath;

  const SettingsSectionHeaderWidget({
    super.key,
    required this.title,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
       Image.asset(iconPath, width: 24.r, height: 24.r,),
        SizedBox(width: 8.w),
        Text(
          title,
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            lineHeight: 12,
          ),
        ),
      ],
    );
  }
}

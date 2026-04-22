import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class CustomButton2 extends StatelessWidget {
  final VoidCallback ontap;
  final String title;
  final Color? bgColor;
  final Color? borderColor;
  final Color? iconBgColor;
  final Color? titleColor;
  final Widget? icon;
  final Color? iconColor;

  const CustomButton2({
    super.key,
    required this.ontap,
    required this.title,
    this.bgColor,
    this.titleColor,
    this.icon,
    this.iconColor,
    this.borderColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.orangeColor,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: titleColor ?? AppColors.whiteColor,
                lineHeight: 14,
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    iconBgColor ?? AppColors.whiteColor.withValues(alpha: 0.3),
              ),
              child:
                  icon ??
                  Image.asset(
                    IconPath.arrowUpRight,
                    color: iconColor ?? AppColors.whiteColor,
                    height: 18.h,
                    width: 18.w,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

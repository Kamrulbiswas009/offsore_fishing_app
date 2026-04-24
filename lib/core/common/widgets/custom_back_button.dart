import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? ontap;
  final Widget? icon;
  final Color? bgColor;
  
  const CustomBackButton({
    super.key, this.ontap, this.icon, this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor ?? AppColors.black2A2F3AColor,
        ),
        child: icon ?? Icon(Icons.arrow_back, color: AppColors.whiteColor, size: 20.r),
      ),
    );
  }
}
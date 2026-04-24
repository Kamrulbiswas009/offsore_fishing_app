import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class JoinGroupCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const JoinGroupCardWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 42.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.tealColor117A88, width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.blue0D2B43Color.withValues(alpha: 0.92),
                AppColors.blue1B2134Color.withValues(alpha: 0.96),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              CustomBackButton(
                bgColor: AppColors.blue00D4FF66Color.withValues(alpha: 0.2),
                icon: Image.asset(IconPath.keyIcon, height: 24.h, width: 24.w),
              ),
              SizedBox(height: 16.h),
              Text(
                "Join with Code",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
              //SizedBox(height: 10.h),
              Text(
                "Enter an invite code to join a group",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    ontap: onTap,
                    title: "Join Group",
                    bgColor: AppColors.orangeColor,
                    titleColor: AppColors.whiteColor,
                    borderRadius: 8.r,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



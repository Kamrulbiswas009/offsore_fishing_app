import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/onboarding/controller/onboarding_screen_controller.dart';

class OnboardingIndexTracker extends StatelessWidget {
  final OnboardingScreenController controller;

  const OnboardingIndexTracker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: controller.currentIndex.value == index ? 24.w : 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: controller.currentIndex.value == index
                  ? AppColors.orangeColor
                  : AppColors.whiteColor.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(50.r),
            ),
          ),
        ),
      ),
    );
  }
}

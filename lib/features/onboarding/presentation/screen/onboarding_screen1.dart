import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/onboarding/controller/onboarding_screen_controller.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen2.dart';

class OnboardingScreen1 extends StatelessWidget {
  final OnboardingScreenController controller =
      Get.find<OnboardingScreenController>();
  OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImagePath.onboardingScreen1Image),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                Spacer(flex: 1),
                Text(
                  "On the Bite",
                  style: getTextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.whiteColor,
                    lineHeight: 20,
                  ),
                ),
                Text(
                  "Find the Bite. Share the Intel.",
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor,
                    lineHeight: 12,
                  ),
                ),
                Spacer(flex: 4),
                GestureDetector(
                  onTap: () {
                    controller.goToStep(0, () => OnboardingScreen2());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(
                        color: AppColors.blue00F0FFColor,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ), // blur effect
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor.withValues(
                              alpha: 0.2,
                            ), // semi-transparent
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Get Started",
                                style: getTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.whiteColor,
                                  lineHeight: 12,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.whiteColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                child: Image.asset(
                                  IconPath.arrowUpRight,
                                 // color: AppColors.whiteColor,
                                  height: 18.h,
                                  width: 18.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

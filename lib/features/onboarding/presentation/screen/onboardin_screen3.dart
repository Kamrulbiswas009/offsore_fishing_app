import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button2.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/login_screen.dart';
import 'package:paytonpieper/features/onboarding/controller/onboarding_screen_controller.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen4.dart';
import 'package:paytonpieper/features/onboarding/presentation/widget/onboarding_index_tracker.dart';

class OnboardingScreen3 extends StatelessWidget {
  final OnboardingScreenController controller =
      Get.find<OnboardingScreenController>();
  OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImagePath.onboardingScreen3Image),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      controller.goToStep(2, () => LoginScreen());
                    },
                    child: Text(
                      "skip",
                      style: getTextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        lineHeight: 10,
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Image.asset(
                  IconPath.mapCompasImage,
                  width: 100.w,
                  height: 100.h,
                ),
                SizedBox(height: 30.h),
                Text(
                  "See the bite, zone by zone",
                  style: getTextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    lineHeight: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  "Tap a zone to see recent reports and activity. Hot zones light up when the bite's on",
                  style: getTextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    lineHeight: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                OnboardingIndexTracker(controller: controller),
                Spacer(flex: 3),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        bgColor: AppColors.whiteColor.withValues(alpha: 0.20),
                        ontap: () {
                          controller.goBackToStep(0);
                        },
                        title: 'Back',
                        prefixIcon: Icon(
                          Icons.keyboard_arrow_left,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 36.h,
                        child: CustomButton2(
                          ontap: () {
                            controller.goToStep(2, () => OnboardingScreen4());
                          },
                          title: 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

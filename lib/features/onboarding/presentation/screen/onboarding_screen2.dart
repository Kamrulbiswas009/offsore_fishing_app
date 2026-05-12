import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button2.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/login_screen.dart';
import 'package:paytonpieper/features/onboarding/controller/onboarding_screen_controller.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboardin_screen3.dart';

class OnboardingScreen2 extends StatelessWidget {
  final OnboardingScreenController controller =
      Get.find<OnboardingScreenController>();
  OnboardingScreen2({super.key});

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
              image: AssetImage(ImagePath.onboardingScreen2Image),
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
                      controller.goToStep(1, () => LoginScreen());
                    },
                    child: Text(
                      "Skip",
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
                Image.asset(IconPath.fishingImage, width: 100.w, height: 100.h),
                SizedBox(height: 30.h),
                Text(
                  "Welcome to On the Bite",
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
                  "Everything you need before the run—what's biting, what the conditions look like, and real reports from the water. Add your own and choose who you share them with.",
                  style: getTextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    lineHeight: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                //OnboardingIndexTracker(controller: controller),
                Spacer(flex: 3),
                CustomButton2(
                  ontap: () {
                    controller.goToStep(1, () => OnboardingScreen3());
                  },
                  title: 'Next',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

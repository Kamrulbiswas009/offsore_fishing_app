import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/splash_screen/controller/splash_screen_controller.dart';
import 'package:paytonpieper/features/splash_screen/presentation/widget/gradient_loading_indicator.dart';

class SplashScreen1 extends StatelessWidget {
  final SplashScreenController controller = Get.find<SplashScreenController>();
  SplashScreen1({super.key});

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
              image: AssetImage(ImagePath.splashScreen1Image),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "25°46'N 80°11'W",
                    style: getTextStyle(
                      color: AppColors.blue00D4FFColor.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      lineHeight: 9,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 320.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              IconPath.paytonFishLogo,
                              width: 86.w,
                              height: 91.h,
                            ),
                            Text(
                              "ON THE BITE",
                              style: getTextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                lineHeight: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Offshore Intelligence Network",
                              style: getTextStyle(
                                color: AppColors.blue00D4FFColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                lineHeight: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "The first ever Offshore Intelligence Network",
                              style: getTextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                lineHeight: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 30.h),
                            Obx(
                              () => GradientLoadingIndicator(
                                progress: controller.loadingProgress.value,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.blue00D4FFColor,
                                  radius: 4.r,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    "INITIALIZING ZONE GRID...",
                                    style: getTextStyle(
                                      color: AppColors.grey8B95A5Color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      lineHeight: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "OFFSHORE INTEL",
                    style: getTextStyle(
                      color: AppColors.blue00D4FFColor.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      lineHeight: 9,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

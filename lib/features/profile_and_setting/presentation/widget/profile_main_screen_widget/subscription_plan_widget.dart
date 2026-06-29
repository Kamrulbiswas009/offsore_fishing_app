import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/subscription_plan_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/model/subscription_plan_model.dart';

class SubscriptionPlanWidget extends StatelessWidget {
  static const Color freePlanBg = Color(0xFF082031);
  static const Color proPlanBg = Color(0xFF252325);
  static Color featureBg = AppColors.blue00D4FFColor.withValues(alpha: 0.2);

  const SubscriptionPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionPlanController());

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 500.w,
        child: CustomPaint(
          painter: GradientBorderPainter(
            strokeWidth: 1.r,
            borderRadius: 16.r,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.blue00D4FFColor.withValues(alpha: 0.5),
                AppColors.orangeFF6B35Color.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                color: featureBg,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 25,
                          child: Container(
                           alignment: Alignment.center,
                            color: featureBg,
                            child: Text("Features", 
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteColor,
                                lineHeight: 12,
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.black.withValues(alpha: 0.06),
                          width: 1,
                          thickness: 1,
                        ),
                        Expanded(
                          flex: 30,
                          child: Container(
                            color: freePlanBg,
                            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.freePlan.name,
                                  style: getTextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.whiteColor,
                                    lineHeight: 10
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  controller.freePlan.price,
                                  style: getTextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.whiteColor,
                                    lineHeight: 13
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  controller.freePlan.subtext,
                                  style: getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.whiteColor,
                                    lineHeight: 9
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.black.withValues(alpha: 0.06),
                          width: 1,
                          thickness: 1,
                        ),
                        Expanded(
                          flex: 35,
                          child: Container(
                            color: proPlanBg,
                            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.proPlan.name,
                                        style: getTextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.orangeFF6B35Color,
                                          lineHeight: 10,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.orangeFF6B35Color,
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          controller.proPlan.badgeText,
                                          style: getTextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        controller.proPlan.price,
                                        style: getTextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.whiteColor,
                                          lineHeight: 13
                                        ),
                                      ),
                                      Text(
                                        controller.proPlan.period,
                                        style: getTextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  controller.proPlan.subtext,
                                  style: getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.whiteColor,
                                    lineHeight: 9
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black.withValues(alpha: 0.06),
                    height: 1,
                    thickness: 1,
                  ),
    
                  // Feature Rows
                  ...controller.features.map((feature) {
                    final isLast = controller.features.last == feature;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 25,
                                child: Container(
                                  color: featureBg,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 14.h,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    feature.featureName,
                                    textAlign: TextAlign.left,
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.whiteColor,
                                      lineHeight: 10
                                    ),
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.black.withValues(alpha: 0.06),
                                width: 1,
                                thickness: 1,
                              ),
                              Expanded(
                                flex: 30,
                                child: Container(
                                  color: freePlanBg,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 14.h,
                                  ),
                                  child: _buildValueCell(
                                    value: feature.freeValue,
                                    color: AppColors.blue00D4FFColor,
                                  ),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.black.withValues(alpha: 0.06),
                                width: 1,
                                thickness: 1,
                              ),
                              Expanded(
                                flex: 35,
                                child: Container(
                                  color: proPlanBg,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 14.h,
                                  ),
                                  child: _buildValueCell(
                                    value: feature.proValue,
                                    color: AppColors.orangeFF6B35Color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            color: Colors.black.withValues(alpha: 0.06),
                            height: 1,
                            thickness: 1,
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueCell({
    required SubscriptionFeatureValue value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18.r,
              height: 18.r,
              child: value.assetPath != null
                  ? Image.asset(
                      value.assetPath!,
                      color: color,
                      colorBlendMode: BlendMode.srcIn,
                    )
                  : (value.iconData != null
                      ? Icon(
                          value.iconData,
                          color: color,
                          size: 16.r,
                        )
                      : const SizedBox()),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value.text,
                textAlign: TextAlign.left,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
            ),
          ],
        ),
        if (value.subtext != null) ...[
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.only(left: 26.w),
            child: Text(
              value.subtext!,
              textAlign: TextAlign.left,
              style: getTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.whiteColor,
                lineHeight: 8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double borderRadius;
  final Gradient gradient;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.borderRadius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
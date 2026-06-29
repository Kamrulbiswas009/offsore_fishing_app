import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';

//TO-Do after client review it should be delete--
class SubscriptionPlanCardWidget extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final VoidCallback onUpgradeTap;

  const SubscriptionPlanCardWidget({
    super.key,
    required this.plan,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.tealColor117A88.withValues(alpha: 0.35),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealColor117A88.withValues(alpha: 0.20),
            Color(0xFF0B3C5D).withValues(alpha: 0.20),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      plan.description,
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey8B95A5Color,
                        lineHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                plan.price,
                style: getTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteColor,
                  lineHeight: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          for (final String feature in plan.features) ...[
            Row(
              children: [
                Container(
                  width: 16.r,
                  height: 16.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greyC8D0DBColor),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    feature,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyC8D0DBColor,
                      lineHeight: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
          ],
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              ontap: onUpgradeTap,
              title: 'Unlock Pro Intel',
              bgColor: AppColors.orangeFF6B35Color,
              borderRadius: 16.r,
              //padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
          ),
        ],
      ),
    );
  }
}

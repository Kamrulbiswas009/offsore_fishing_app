import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CustomBackButton(ontap: Get.back),
                  Expanded(
                    child: Text(
                      'Help & Support',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: AppColors.containerBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.tealColor117A88),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Name',
                      value: 'Payton Pieper',
                    ),
                    Divider(
                      color: AppColors.tealColor117A88.withValues(alpha: 0.35),
                      height: 24.h,
                    ),
                    _buildInfoItem(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: '5992 Alder Ave Pensacola FL 32526',
                    ),
                    Divider(
                      color: AppColors.tealColor117A88.withValues(alpha: 0.35),
                      height: 24.h,
                    ),
                    _buildInfoItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'admin@onthebitefishing.com',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.tealColor117A88.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.tealColor117A88, size: 20.r),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/submit_report/controller/submit_report_controller.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import '../../../../core/utils/constants/colors.dart';

class VisibilitySharingDialog extends StatelessWidget {
  const VisibilitySharingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisibilitySharingController());

    return Dialog(
      backgroundColor: AppColors.backgroundDarkColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Visibility & Sharing *",
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      // lineHeight: 20,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              Text(
                "Choose where to share this report\n(select at least one)",
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(height: 25.h),

              // --- Public Feed Option ---
              Obx(
                () => _buildSelectionCard(
                  title: "Public Feed",
                  subtitle: "Share with all On the Bite users",
                  icon: Icons.public,
                  isSelected: controller.isPublicSelected.value,
                  onTap: controller.togglePublic,
                ),
              ),
              SizedBox(height: 20.h),

              // --- Private Groups Section ---
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.blue1B2134Color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          color: AppColors.grey8B95A5Color,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Private Groups",
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8B95A5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Share with selected groups only",
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.grey516173Color,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Column(
                      children: controller.privateGroups.map((group) {
                        return Obx(
                          () => _buildGroupCard(
                            title: group['name'],
                            subtitle: "${group['members']} members",
                            isSelected: controller.selectedGroups.contains(
                              group['id'],
                            ),
                            onTap: () => controller.toggleGroup(group['id']),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // --- Error Warning Message ---
              Obx(
                () => !controller.hasSelection
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.maroon271B2CColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.redDA605CColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.redDA605CColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                "Please select at least one sharing option",
                                style: getTextStyle(
                                  fontSize: 13,
                                  color: AppColors.redDA605CColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),

              SizedBox(height: 25.h),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  ontap: controller.submitReport,
                  title: "Submit Report",
                  bgColor: AppColors.orangeColor,
                  titleColor: Colors.white,
                  fontSize: 18,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  borderRadius: 22.r,
                  borderColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.blue00F0FFColor
                : AppColors.grey3A4B62Color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon(icon, color: AppColors.greyC8D0DBColor, size: 28.sp),
            Image.asset(IconPath.world, height: 28.h, width: 28.w),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey8B95A5Color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.blue00F0FFColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: getTextStyle(
                      fontSize: 12,
                      color: AppColors.grey516173Color,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.blue00F0FFColor,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}

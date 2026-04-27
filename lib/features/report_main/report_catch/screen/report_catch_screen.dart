import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/features/report_main/report_catch/controller/report_catch_step1_screen.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import '../../../../core/utils/constants/colors.dart';

class ReportCatchStep1Screen extends GetView<ReportCatchController> {
  const ReportCatchStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: CircleAvatar(
            backgroundColor: AppColors.blue1B2134Color,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          "Report Catch",
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      // FIX 1: Wrap body in SingleChildScrollView to fix 196px Bottom Overflow
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // 1. Sync Status Bar
              _buildSyncStatusBar(),
              SizedBox(height: 30.h),

              // 2. Stepper Header (FIXED for Horizontal Overflow)
              _buildStepper(),
              SizedBox(height: 30.h),

              Text(
                "Select Grid Location",
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),

              // 3. Selection Cards
              Obx(
                () => _buildSelectionCard(
                  title: "Use Current Location",
                  subtitle: "Auto-detect grid from GPS",
                  icon: Icons.location_on,
                  isSelected: controller.isGpsSelected.value,
                  onTap: controller.selectGps,
                  footer: "Detected Grid: ${controller.detectedGrid.value}",
                ),
              ),
              SizedBox(height: 15.h),

              Obx(
                () => _buildSelectionCard(
                  title: "Select Manually",
                  subtitle: "Choose grid from map",
                  icon: Icons.map,
                  isSelected: !controller.isGpsSelected.value,
                  onTap: controller.selectManual,
                ),
              ),

              SizedBox(height: 40.h),

              // 4. Action Button
              _buildConfirmButton(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi, color: AppColors.green10B981Color, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                "Online - Report will sync instantly",
                style: getTextStyle(
                  fontSize: 13,
                  color: AppColors.green10B981Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            "offline / queued state Reports should save and sync automatically when connection returns",
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 11,
              color: AppColors.yellowFCEA74Color,
            ),
          ),
        ],
      ),
    );
  }

  // FIX 2: Fixed Horizontal Overflow by using Flexible and constrained widths
  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepperCircle("1", true),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            "Select Grid",
            maxLines: 1,
            style: getTextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          width: 30.w, // Reduced width to prevent overflow
          height: 1.h,
          color: AppColors.grey3A4B62Color,
        ),
        _stepperCircle("2", false),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            "Report Details",
            maxLines: 1,
            style: getTextStyle(fontSize: 14, color: AppColors.grey516173Color),
          ),
        ),
      ],
    );
  }

  Widget _stepperCircle(String num, bool isActive) {
    return Container(
      width: 26.r,
      height: 26.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.teal0C98AFColor : AppColors.blue1B2134Color,
        border: isActive ? null : Border.all(color: AppColors.grey3A4B62Color),
      ),
      alignment: Alignment.center,
      child: Text(
        num,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : AppColors.grey516173Color,
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
    String? footer,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.tealColor117A88 : Colors.transparent,
            width: 1.5.w,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.teal163A42Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.blue00F0FFColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 15.w),
                // Use Expanded to prevent text overflow inside the card
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        subtitle,
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey8B95A5Color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.blue00F0FFColor,
                    size: 22.sp,
                  ),
              ],
            ),
            if (footer != null) ...[
              SizedBox(height: 5.h),
              Divider(
                color: AppColors.grey3A4B62Color.withOpacity(0.3),
                thickness: 1,
              ),
              // SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Detected Grid: ",
                    style: getTextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    controller.detectedGrid.value,
                    style: getTextStyle(
                      fontSize: 14,
                      color: AppColors.blue00F0FFColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        ontap: controller.confirmGrid,
        title: "Confirm Grid",
        bgColor: AppColors.orangeColor,
        titleColor: Colors.white,
        fontSize: 18,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        borderRadius: 30.r,
        borderColor: Colors.transparent,
      ),
    );
  }
}

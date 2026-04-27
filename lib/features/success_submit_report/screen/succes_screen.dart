import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/features/success_submit_report/controller/success_controller.dart';
import '../../../../core/utils/constants/colors.dart';

class ReportSuccessScreen extends StatelessWidget {
  const ReportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Putting controller here since it's a terminal screen
    final controller = Get.put(ReportSuccessController());

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: CircleAvatar(
            backgroundColor: AppColors.blue1B2134Color,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 18.sp),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // 1. Success Icon & Message Card
              _buildSuccessHeader(),
              SizedBox(height: 20.h),

              // 2. Report Summary Card (Gradient)
              _buildSummaryCard(controller),
              SizedBox(height: 20.h),

              // 3. Community Tip Box
              _buildTipBox(),

              SizedBox(height: 40.h),

              // 4. Action Buttons
              _buildActionButtons(controller),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.blue00F0FFColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue00F0FFColor.withOpacity(0.1),
              border: Border.all(color: AppColors.blue00F0FFColor, width: 2),
            ),
            child: Icon(
              Icons.check,
              color: AppColors.blue00F0FFColor,
              size: 40.sp,
            ),
          ),
          SizedBox(height: 25.h),
          Text(
            "Report Submitted!",
            style: getTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Your fishing intel is now live",
            style: getTextStyle(fontSize: 16, color: AppColors.grey8B95A5Color),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ReportSuccessController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C5364), // Deep Teal/Blue
            Color(0xFFE25301), // Orange
          ],
          stops: [0.3, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.assignment_outlined, color: Colors.white, size: 24.sp),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.species,
                style: getTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                "Zone ${controller.zone}",
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                controller.sharingInfo,
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.blue1B2134Color, width: 1.5),
      ),
      child: Text(
        "Your report helps the community identify active fishing patterns. Keep sharing your catches!",
        textAlign: TextAlign.center,
        style: getTextStyle(fontSize: 13, color: AppColors.grey516173Color),
      ),
    );
  }

  Widget _buildActionButtons(ReportSuccessController controller) {
    return Column(
      children: [
        // View Report Button
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: ElevatedButton(
            onPressed: controller.viewReport,
            style: ElevatedButton.styleFrom(
              side: BorderSide(color: Colors.transparent),
              backgroundColor: AppColors.orangeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  "View My Report",
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.h),

        // Add Another Button
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: OutlinedButton(
            onPressed: controller.addAnother,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.blue00F0FFColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.blue00F0FFColor, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  "Add Another Report",
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue00F0FFColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.h),

        // Close Button
        TextButton(
          onPressed: controller.close,
          child: Text(
            "Close",
            style: getTextStyle(
              fontSize: 16,
              color: AppColors.grey516173Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/report/model/report_model.dart';

import '../../controller/summary_details_controller.dart';

class ReportTabWidget extends GetView<SummaryController> {
  const ReportTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "My Reports",
          style: getTextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Track your fishing activity",
          style: getTextStyle(fontSize: 14, color: AppColors.grey8B95A5Color),
        ),
        SizedBox(height: 20.h),

        // 1. Dynamic Filters
        _buildReportFilters(),
        SizedBox(height: 20.h),

        // 2. Pattern Indicator
        _buildPatternIndicator("3 Reports . Same Pattern"),
        SizedBox(height: 20.h),

        // 3. Reports List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.reports.length,
          separatorBuilder: (context, index) => SizedBox(height: 15.h),
          itemBuilder: (context, index) {
            return _buildReportCard(controller.reports[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildReportFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterDropdown(controller.selectedSpecies),
          _filterDropdown(controller.selectedDepth),
          _filterDropdown(controller.selectedTechnique),
          _filterDropdown(controller.selectedTime),
        ],
      ),
    );
  }

  Widget _filterDropdown(RxString selectedValue) {
    return Obx(
      () => Container(
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.blue1B2134Color,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grey3A4B62Color),
        ),
        child: Row(
          children: [
            Text(
              selectedValue.value,
              style: getTextStyle(fontSize: 13, color: Colors.white),
            ),
            SizedBox(width: 5.w),
            Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternIndicator(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.green10B981Color.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            text,
            style: getTextStyle(
              fontSize: 12,
              color: AppColors.green10B981Color,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.green10B981Color.withOpacity(0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(FishingReport report, int index) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    report.title,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Icon(
                    Icons.check_circle,
                    color: AppColors.blue00F0FFColor,
                    size: 16.sp,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.orangeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "${report.confirms} confirms",
                  style: getTextStyle(
                    fontSize: 11,
                    color: AppColors.orangeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            report.author != null
                ? "by ${report.author} . ${report.timeAgo}"
                : report.timeAgo,
            style: getTextStyle(
              fontSize: 12,
              color: AppColors.grey8B95A5Color,
            ),
          ),
          SizedBox(height: 15.h),

          // Data Grid
          Row(
            children: [
              Expanded(child: _reportInfoLabel("Depth:", report.depth)),
              Expanded(child: _reportInfoLabel("Zone:", report.zone)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                  child: _reportInfoLabel("Technique:", report.technique)),
              Expanded(child: _reportInfoLabel("Bait:", report.bait)),
            ],
          ),

          if (report.note != null) ...[
            const Divider(color: AppColors.blue153A56Color, height: 30),
            Text(
              report.note!,
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.greyC8D0DBColor,
                fontWeight: FontWeight.w300,
                lineHeight: 1.4,
              ),
            ),
          ],

          SizedBox(height: 15.h),

          // Clickable Confirm Button
          InkWell(
            onTap: () => controller.confirmBite(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: Colors.white, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Confirm Bite",
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportInfoLabel(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label ",
            style: getTextStyle(
              fontSize: 13,
              color: AppColors.grey8B95A5Color,
            ),
          ),
          TextSpan(
            text: value,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

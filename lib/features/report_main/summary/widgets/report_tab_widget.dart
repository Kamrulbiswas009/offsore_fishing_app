// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/report_main/report/model/report_model.dart';

import '../controller/summary_details_controller.dart';

class ReportTabWidget extends GetView<SummaryController> {
  const ReportTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddReportButton(),
        SizedBox(height: 20.h),
        Text(
          "Zone Reports",
          style: getTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            lineHeight: 24,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          "Reports from this zone",
          style: getTextStyle(
            fontSize: 14,
            color: AppColors.grey8B95A5Color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.h),

        // 1. Dynamic Filters
        _buildReportFilters(),
        SizedBox(height: 20.h),

        // 3. Reports List
        Obx(() {
          if (controller.isLoading.value) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangeColor),
                ),
              ),
            );
          }
          final list = controller.filteredReports;
          if (list.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Center(
                child: Text(
                  "No reports found matching filters.",
                  style: getTextStyle(
                    fontSize: 14,
                    color: AppColors.grey8B95A5Color,
                  ),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatternIndicator("${list.length} Reports • Same Pattern"),
              SizedBox(height: 20.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, index) => SizedBox(height: 15.h),
                itemBuilder: (context, index) {
                  return _buildReportCard(list[index], index);
                },
              ),
            ],
          );
        }),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildReportFilters() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 4.w),
            child: Row(
              children: [
                _filterDropdown(
                  controller.selectedReportType,
                  controller.reportTypeList,
                  "Reports",
                ),
                _filterDropdown(
                  controller.selectedSpecies,
                  controller.speciesList,
                  "Species",
                ),
                _filterDropdown(
                  controller.selectedDepth,
                  controller.depthList,
                  "Depth",
                ),
                _filterDropdown(
                  controller.selectedTechnique,
                  controller.techniqueList,
                  "Technique",
                ),
                _filterDropdown(
                  controller.selectedTime,
                  controller.timeList,
                  "Time",
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        InkWell(
          onTap: () => controller.resetFilters(),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.blue1B2134Color,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.grey3A4B62Color),
            ),
            child: Icon(Icons.refresh, color: Colors.white, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _filterDropdown(
    RxString selectedValue,
    List<String> options,
    String placeholder,
  ) {
    return Obx(
      () => PopupMenuButton<String>(
        onSelected: (String value) {
          selectedValue.value = value;
        },
        offset: const Offset(0, 40),
        color: AppColors.blue1B2134Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: const BorderSide(color: AppColors.grey3A4B62Color),
        ),
        itemBuilder: (BuildContext context) {
          return options.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(
                choice,
                style: getTextStyle(fontSize: 13, color: Colors.white),
              ),
            );
          }).toList();
        },
        child: Container(
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
                selectedValue.value.isEmpty ? placeholder : selectedValue.value,
                style: getTextStyle(fontSize: 13, color: Colors.white),
              ),
              SizedBox(width: 5.w),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18.sp),
            ],
          ),
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
            thickness: 2,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            text,
            style: getTextStyle(
              lineHeight: 20,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.green10B981Color,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.green10B981Color.withOpacity(0.3),
            thickness: 2,
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
        border: Border.all(
          color: AppColors.blue00D4FFColor.withValues(alpha: 0.3),
        ),
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
                    fontSize: 12,
                    color: AppColors.orangeColor,
                    fontWeight: FontWeight.w400,
                    lineHeight: 16,
                  ),
                ),
              ),
            ],
          ),
          Text(
            report.author != null
                ? "by ${report.author} . ${report.timeAgo}"
                : report.timeAgo,
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
          ),
          SizedBox(height: 8.h),

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
              Expanded(child: _reportInfoLabel("Technique:", report.technique)),
              Expanded(child: _reportInfoLabel("Bait:", report.bait)),
            ],
          ),

          if (report.note != null) ...[
            const Divider(color: AppColors.blue153A56Color, height: 20),
            Text(
              report.note!,
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.greyC8D0DBColor,
                fontWeight: FontWeight.w300,
                lineHeight: 14,
              ),
            ),
          ],

          SizedBox(height: 12.h),

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
                  Image.asset(IconPath.hookIcon, width: 16.w, height: 16.h),

                  SizedBox(width: 4.w),
                  Text(
                    "Confirm Bite",
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      lineHeight: 20,
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
              fontSize: 14,
              color: AppColors.grey8B95A5Color,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: value,
            style: getTextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReportButton() {
    return InkWell(
      onTap: controller.onAddReport,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.orangeFF6B35Color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              "Add Report",
              style: getTextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                lineHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

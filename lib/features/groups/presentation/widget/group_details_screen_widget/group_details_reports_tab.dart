import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/model/group_details_model.dart';

class GroupDetailsReportsTab extends GetView<GroupDetailsScreenController> {
  const GroupDetailsReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Group Reports',
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
            ),
            CustomButton(
              ontap: () {},
              title: ' Add Report',
              fontSize: 14,
              lineHeight: 10,
              bgColor: Color(0xFF055467),
              prefixIcon: Icon(
                Icons.add,
                color: AppColors.whiteColor,
                size: 18.r,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ReportFilterDropdown(
                selectedValue: controller.selectedReportSpecies,
                filter: controller.speciesFilter,
                onSelected: controller.selectReportSpecies,
              ),
              SizedBox(width: 6.w),
              _ReportFilterDropdown(
                selectedValue: controller.selectedReportDepth,
                filter: controller.depthFilter,
                onSelected: controller.selectReportDepth,
              ),
              SizedBox(width: 6.w),
              _ReportFilterDropdown(
                selectedValue: controller.selectedReportMethod,
                filter: controller.methodFilter,
                onSelected: controller.selectReportMethod,
              ),
              SizedBox(width: 6.w),
              _ReportFilterDropdown(
                selectedValue: controller.selectedReportTime,
                filter: controller.timeFilter,
                onSelected: controller.selectReportTime,
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        ...controller.reports.map((report) => _ReportCard(report: report)),
      ],
    );
  }
}

class _ReportFilterDropdown extends StatelessWidget {
  final RxnString selectedValue;
  final GroupReportFilterOption filter;
  final ValueChanged<String> onSelected;

  const _ReportFilterDropdown({
    required this.selectedValue,
    required this.filter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final String text = selectedValue.value ?? filter.label;

      return PopupMenuButton<String>(
        onSelected: onSelected,
        offset: Offset(0, 38.h),
        color: AppColors.blue1B2134Color,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: const BorderSide(color: AppColors.grey516173Color),
        ),
        itemBuilder: (BuildContext context) {
          return filter.options.map((String option) {
            return PopupMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          height: 38.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.blue1B2134Color,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.grey8B95A5Color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
              SizedBox(width: 5.w),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.whiteColor,
                size: 17.r,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ReportCard extends StatelessWidget {
  final GroupReportItem report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.black0F1E33Color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.whiteColor,
                    lineHeight: 12,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.orangeColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  report.zone,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orangeFF6B35Color,
                    lineHeight: 9,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'by ${report.author} · ${report.timeAgo}',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey8B95A5Color,
              lineHeight: 10,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _MetaText(title: 'Depth', value: report.depth),
              SizedBox(width: 16.w),
              _MetaText(title: 'Technique', value: report.technique),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '"${report.note}"',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey8B95A5Color,
              lineHeight: 10,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.blue00D4FFColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.done_sharp,
                      color: AppColors.blue00D4FFColor,
                      size: 12.r,
                    ),

                    SizedBox(width: 4.w),
                    Text(
                      'Success',
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blue00D4FFColor,
                        lineHeight: 9,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${report.confirmations} confirmations',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String title;
  final String value;

  const _MetaText({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$title: ',
        style: getTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey8B95A5Color,
          lineHeight: 10,
        ),
        children: [
          TextSpan(
            text: value,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteColor,
              lineHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

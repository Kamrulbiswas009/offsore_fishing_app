import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/global_map_box.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/report_main/offline_report/controller/offline_report_controller.dart';
import 'package:paytonpieper/features/report_main/offline_report/model/offline_report_model.dart';
import '../../../../core/utils/constants/colors.dart';

class OfflineReportsScreen extends GetView<OfflineReportsTabController> {
  const OfflineReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: Column(
        children: [
          _buildHeaderMap(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildTabSwitcher(),
                  SizedBox(height: 20.h),
                  _buildAddReportButton(),
                  SizedBox(height: 20.h),
                  _buildPendingSyncCard(),
                  SizedBox(height: 10.h),
                  Text(
                    "My Reports",
                    style: getTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Track your fishing activity",
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildFilterRow(),
                  SizedBox(height: 20.h),
                  _buildPatternLine(),
                  SizedBox(height: 5.h),
                  _buildReportList(),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMap() {
    return Stack(
      children: [
        GlobalRealMapBox(center: LatLng(25.7617, -80.1918), zoom: 13.0),
        Obx(
          () => controller.isSyncing.value
              ? Container(
                  width: double.infinity,
                  color: AppColors.orangeFF6B35Color.withOpacity(0.8),
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, size: 14.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        "Syncing ${controller.pendingSyncCount} pending reports...",
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Row(
      children: ["Summary", "Reports", "Weather"]
          .map(
            (tab) => Expanded(
              child: Obx(
                () => GestureDetector(
                  onTap: () => controller.selectedTab.value = tab,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: controller.selectedTab.value == tab
                          ? AppColors.teal163A42Color.withOpacity(0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: controller.selectedTab.value == tab
                            ? AppColors.blue00F0FFColor
                            : AppColors.grey3A4B62Color,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab,
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAddReportButton() {
    return GestureDetector(
      onTap: () => Get.toNamed('/addReport'),
      child: Container(
        height: 55.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            "+ Add Report",
            style: getTextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingSyncCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.blue00F0FFColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, color: AppColors.blue00F0FFColor, size: 24.sp),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${controller.pendingSyncCount} Reports Pending Sync",
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Syncing your reports to the server...",
                style: getTextStyle(
                  fontSize: 13,
                  color: AppColors.grey8B95A5Color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(controller.speciesFilter, controller.speciesOptions),
          _filterChip(controller.depthFilter, controller.depthOptions),
          _filterChip(controller.techniqueFilter, controller.techniqueOptions),
          _filterChip(controller.timeFilter, controller.timeOptions),
        ],
      ),
    );
  }

  Widget _filterChip(RxString val, List<String> options) {
    return Obx(
      () => PopupMenuButton<String>(
        onSelected: (String newValue) {
          val.value = newValue;
        },
        offset: const Offset(0, 45),
        color: AppColors.blue1B2134Color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: AppColors.grey3A4B62Color.withOpacity(0.5)),
        ),
        itemBuilder: (BuildContext context) {
          return options.map((String option) {
            return PopupMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: getTextStyle(fontSize: 14, color: Colors.white),
              ),
            );
          }).toList();
        },
        child: Container(
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.blue1B2134Color,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.grey3A4B62Color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                val.value,
                style: getTextStyle(fontSize: 13, color: Colors.white),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatternLine() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.grey3A4B62Color.withOpacity(0.5)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "3 Reports . Same Pattern",
            style: getTextStyle(
              fontSize: 12,
              color: AppColors.green10B981Color,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.grey3A4B62Color.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _buildReportList() {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.reports.length,
        separatorBuilder: (context, index) => SizedBox(height: 15.h),
        itemBuilder: (context, index) => _reportCard(controller.reports[index]),
      ),
    );
  }

  Widget _reportCard(OfflineReportModel report) {
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
                    report.subSpecies != null
                        ? "${report.species} (${report.subSpecies})"
                        : report.species,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (report.isVerified) ...[
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.blue00F0FFColor,
                      size: 16.sp,
                    ),
                  ],
                ],
              ),
              _confirmBadge("${report.confirms} confirms"),
            ],
          ),
          Text(
            report.author != null
                ? "by ${report.author} . ${report.timeAgo}"
                : report.timeAgo,
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
          ),
          SizedBox(height: 15.h),
          _reportInfoRow("Depth:", report.depth, "Zone:", report.zone),
          SizedBox(height: 8.h),
          _reportInfoRow("Technique:", report.technique, "Bait:", report.bait),
          if (report.note != null) ...[
            Divider(color: AppColors.blue153A56Color, height: 30.h),
            Text(
              report.note!,
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.greyC8D0DBColor,
              ),
            ),
          ],
          SizedBox(height: 20.h),
          _confirmButton(report.id),
        ],
      ),
    );
  }

  Widget _reportInfoRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$l1 ",
                  style: getTextStyle(
                    fontSize: 13,
                    color: AppColors.grey8B95A5Color,
                  ),
                ),
                TextSpan(
                  text: v1,
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$l2 ",
                  style: getTextStyle(
                    fontSize: 13,
                    color: AppColors.grey8B95A5Color,
                  ),
                ),
                TextSpan(
                  text: v2,
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _confirmBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.orangeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: getTextStyle(
          fontSize: 11,
          color: AppColors.orangeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _confirmButton(String id) {
    return GestureDetector(
      onTap: () => controller.onConfirmBite(id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(IconPath.hookIcon, height: 24.h, width: 24.w),

            SizedBox(width: 4.w),
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
    );
  }
}

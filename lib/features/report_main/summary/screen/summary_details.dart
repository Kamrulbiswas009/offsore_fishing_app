import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/global_map_box.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/report/model/report_model.dart';

import '../controller/summary_details_controller.dart';

class SummaryScreen extends GetView<SummaryController> {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const GlobalRealMapBox(
              center: LatLng(25.7617, -80.1918), // Focused on Miami Coast
              height: 240,
            ), // Reusable Component

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildTabSwitcher(),
                  SizedBox(height: 20.h),
                  Obx(() {
                    final selectedTab = controller.selectedTab.value;
                    if (selectedTab == 'Reports') {
                      return _buildReportsTab();
                    }
                    if (selectedTab == 'Weather') {
                      return _buildWeatherTab();
                    }
                    return _buildSummaryTab();
                  }),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
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
                          ? AppColors.tealColor117A88.withOpacity(0.4)
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
                        fontWeight: FontWeight.w600,
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

  Widget _buildSummaryTab() {
    return Column(
      children: [
        _buildAddReportButton(),
        SizedBox(height: 20.h),
        _buildUpdateHeader(),
        SizedBox(height: 20.h),
        _buildActivityOverview(),
        SizedBox(height: 25.h),
        _buildMarineConditions(),
        SizedBox(height: 25.h),
        _buildPatternIntelligence(),
        SizedBox(height: 25.h),
        _buildActivityTiming(),
        SizedBox(height: 25.h),
        _buildTopSpecies(),
      ],
    );
  }

  Widget _buildWeatherTab() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
      ),
      child: Text(
        'Weather content will appear here.',
        style: getTextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildAddReportButton() {
    return InkWell(
      onTap: controller.onAddReport,
      child: Container(
        height: 55.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white),
            SizedBox(width: 10.w),
            Text(
              "Add Report",
              style: getTextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.blue1B2134Color,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.white),
              SizedBox(width: 10.w),
              Text(
                "Last 3 Days",
                style: getTextStyle(fontSize: 12, color: Colors.white),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              "Updated 2 min ago",
              style: getTextStyle(
                fontSize: 11,
                color: AppColors.blue00F0FFColor,
              ),
            ),
            SizedBox(width: 5.w),
            const Icon(
              Icons.refresh,
              size: 16,
              color: AppColors.blue00F0FFColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.bolt, "Activity Overview"),
        Row(
          children: [
            _statCard("LAST 24H", "8", "Reports", AppColors.blue00F0FFColor),
            _statCard("SUCCESS", "78%", "Hit Rate", AppColors.orangeColor),
            _statCard("HOT ZONES", "2", "Active", AppColors.blue00F0FFColor),
            _statCard("GROUPS", "3", "Networks", AppColors.orangeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildMarineConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.air, "Marine Conditions - Zone A-7"),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.blue0D2B43Color,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.blue153A56Color.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _marineItem(Icons.air, "12", "mph SE"),
                  _verticalDivider(),
                  _marineItem(Icons.waves, "2.5", "ft"),
                  _verticalDivider(),
                  _marineItem(Icons.thermostat, "78°", "F"),
                  _verticalDivider(),
                  _marineItem(Icons.water_drop, "1.2", "Rising"),
                  _verticalDivider(),
                  _marineItem(
                    Icons.cloud_queue,
                    "Partly",
                    "Cloudy",
                    isWeather: true,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () =>
                    Get.snackbar("Forecast", "Loading full marine forecast..."),
                child: Container(
                  height: 48.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.blue00F0FFColor,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "View Full Forecast",
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue0D2B43Color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _marineItem(
    IconData icon,
    String val,
    String unit, {
    bool isWeather = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.blue00F0FFColor, size: 20.sp),
        SizedBox(height: 8.h),
        Text(
          val,
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: getTextStyle(fontSize: 10, color: AppColors.grey8B95A5Color),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30.h,
      width: 1,
      color: AppColors.grey3A4B62Color.withOpacity(0.5),
    );
  }

  Widget _statCard(String label, String val, String sub, Color accent) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: getTextStyle(
                fontSize: 8,
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              val,
              style: getTextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(sub, style: getTextStyle(fontSize: 9, color: accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTiming() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACTIVITY TIMING",
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "24 Hours Ago",
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.blue00F0FFColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "peak window",
                      style: getTextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      "6.00 AM - 10.00 AM",
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.blue00F0FFColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue1B2134Color,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Trolling",
                        style: getTextStyle(
                          fontSize: 11,
                          color: AppColors.blue00F0FFColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 100.h,
                  child: BarChart(
                    BarChartData(
                      barGroups: controller.activityData,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternIntelligence() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PATTERN INTELLIGENCE",
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _patternItem(
                  "MOST COMMON DEPTH",
                  "120-180 ft",
                  AppColors.blue00F0FFColor,
                ),
              ),
              Expanded(
                child: _patternItem(
                  "MOST EFFECTIVE METHOD",
                  "Trolling",
                  AppColors.blue00F0FFColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _patternItem(
                  "TOP BAIT / LURE",
                  "Blue/White Ilander",
                  AppColors.blue00F0FFColor,
                ),
              ),
              Expanded(
                child: _patternItem(
                  "STRIKE ZONE",
                  "Mid Column / Thermocline",
                  AppColors.redDA605CColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patternItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 11,
            color: AppColors.greyC8D0DBColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // Common Header helper
  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue00F0FFColor, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: getTextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpecies() {
    final List<Map<String, String>> speciesData = [
      {"name": "Tuna", "count": "06"},
      {"name": "Snapper", "count": "06"},
      {"name": "Grouper", "count": "06"},
      {"name": "Mahi", "count": "06"},
      {"name": "Wahoo", "count": "06"},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w, bottom: 20.h),
            child: Text(
              "TOP SPECIES (LAST 24H)",
              style: getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(speciesData.length * 2 - 1, (index) {
              // Add a vertical divider for every odd index
              if (index.isOdd) {
                return Container(
                  height: 35.h,
                  width: 1,
                  color: AppColors.grey3A4B62Color.withOpacity(0.4),
                );
              }

              // Calculate actual data index
              final dataIndex = index ~/ 2;
              return _speciesItem(
                speciesData[dataIndex]["name"]!,
                speciesData[dataIndex]["count"]!,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _speciesItem(String name, String count) {
    return Column(
      children: [
        // Fish Icon/Image
        Icon(
          Icons
              .set_meal, // Using a generic fish icon, replace with your fish asset if needed
          color: AppColors.blue00F0FFColor,
          size: 20.sp,
        ),
        SizedBox(height: 6.h),
        Text(
          count,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          name,
          style: getTextStyle(
            fontSize: 12,
            color: AppColors.grey516173Color, // Muted grey for the label
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
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
            style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
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
              Expanded(child: _reportInfoLabel("Technique:", report.technique)),
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
            style: getTextStyle(fontSize: 13, color: AppColors.grey8B95A5Color),
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

  // // --- Implement Other Cards (Marine, Pattern, Species) here using same logic ---
  // Widget _buildMarineConditions() {
  //   return const SizedBox();
  // } // Simplified for brevity

  // Widget _buildPatternIntelligence() {
  //   return const SizedBox();
  // }

  // Widget _buildTopSpecies() {
  //   return const SizedBox();
  // }
}

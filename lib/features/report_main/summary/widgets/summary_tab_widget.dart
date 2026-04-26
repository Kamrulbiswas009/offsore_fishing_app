import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';

import '../controller/summary_details_controller.dart';

class SummaryTabWidget extends GetView<SummaryController> {
  const SummaryTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final zone = controller.selectedZone.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddReportButton(),
          SizedBox(height: 20.h),
          _buildZoneHeader(zone),
          SizedBox(height: 15.h),
          _buildUpdateHeader(),
          SizedBox(height: 25.h),
          _buildActivityOverview(zone),
          SizedBox(height: 30.h),
          _buildMarineConditions(),
          SizedBox(height: 30.h),
          _buildPatternIntelligence(),
          SizedBox(height: 30.h),
          _buildActivityTiming(),
          SizedBox(height: 30.h),
          _buildTopSpecies(),
          SizedBox(height: 30.h),
          _buildSpeciesDistribution(),
          SizedBox(height: 30.h),
        ],
      );
    });
  }

  Widget _buildZoneHeader(MapZoneModel? zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDynamicZoneName(zone?.name ?? 'GOM-12', fontSize: 28),
        SizedBox(height: 4.h),
        Text(
          '${zone?.reports ?? 24} reports • Last updated ${zone?.lastUpdated ?? "6 hours ago"}',
          style: getTextStyle(fontSize: 14, color: Colors.white54),
        ),
      ],
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

  Widget _buildActivityOverview(MapZoneModel? zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.query_stats, "Activity Overview"),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _statCard(
                "LAST 24H",
                "${zone?.reports ?? 8}",
                "Reports",
                AppColors.blue00F0FFColor,
                IconPath.ratioGraph,
              ),
              _statCard(
                "SUCCESS",
                "78%",
                "Hit Rate",
                AppColors.orangeColor,
                IconPath.redFish,
              ),
              _statCard(
                "Peak Time",
                "6-9 am",
                "Peak Window",
                AppColors.blue00F0FFColor,
                IconPath.timeScheduleIcon,
              ),
              _statCard(
                "GROUPS",
                "3",
                "Networks",
                AppColors.orangeColor,
                IconPath.redGroupsIcon,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarineConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.waves, "Marine Conditions - Zone A-7"),
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
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _marineItem(Icons.air, "12", "mph SE"),
                    _vDivider(),
                    _marineItem(Icons.waves, "2.5", "ft"),
                    _vDivider(),
                    _marineItem(Icons.thermostat, "78°", "F"),
                    _vDivider(),
                    _marineItem(Icons.water_drop, "1.2", "Rising"),
                    _vDivider(),
                    _marineItem(
                      Icons.cloud_queue,
                      "Partly",
                      "Cloudy",
                      isWeather: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              GestureDetector(
                onTap: () =>
                    Get.snackbar("Forecast", "Loading full marine forecast..."),
                child: Container(
                  height: 38.h,
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

  Widget _vDivider() {
    return Container(
      width: 1,
      color: AppColors.blue153A56Color.withOpacity(0.5),
    );
  }

  Widget _statCard(
    String label,
    String val,
    String sub,
    Color accent,
    String icon,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(icon, color: accent, height: 14.h, width: 14.w),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    label,
                    style: getTextStyle(
                      fontSize: 8,
                      color: Colors.white54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              val,
              style: getTextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub.isNotEmpty ? sub : " ",
              style: getTextStyle(fontSize: 9, color: accent),
            ),
          ],
        ),
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
          SizedBox(height: 25.h),
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
          SizedBox(height: 25.h),
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
                  AppColors.orangeColor,
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
        SizedBox(height: 8.h),
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

  Widget _buildActivityTiming() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACTIVITY TIMING",
                style: getTextStyle(
                  fontSize: 15,
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
          SizedBox(height: 25.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "peak window",
                      style: getTextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "6.00 AM - 10.00 AM",
                      style: getTextStyle(
                        fontSize: 13,
                        color: AppColors.blue00F0FFColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Most Effective\nTechnique",
                      style: getTextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal0C98AFColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.blue00F0FFColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "Trolling",
                        style: getTextStyle(
                          fontSize: 12,
                          color: AppColors.blue00F0FFColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 120.h,
                  child: BarChart(
                    BarChartData(
                      barGroups: controller.activityData,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 3 == 0) {
                                return Text(
                                  "${value.toInt()} am",
                                  style: getTextStyle(
                                    fontSize: 8,
                                    color: Colors.white38,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
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

  Widget _buildTopSpecies() {
    final List<Map<String, String>> speciesData = [
      {"name": "Tuna", "count": "16"},
      {"name": "Snapper", "count": "12"},
      {"name": "Grouper", "count": "08"},
      {"name": "Mahi", "count": "06"},
      {"name": "Wahoo", "count": "05"},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5.w, bottom: 25.h),
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
              if (index.isOdd) {
                return Container(
                  height: 40.h,
                  width: 1,
                  color: AppColors.grey3A4B62Color.withOpacity(0.3),
                );
              }
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
        Image.asset(
          "assets/icons/fish_icon.png",
          color: AppColors.blue00F0FFColor,
          width: 24.w,
          height: 18.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 8.h),
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
          style: getTextStyle(fontSize: 11, color: AppColors.grey516173Color),
        ),
      ],
    );
  }

  Widget _buildSpeciesDistribution() {
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
            "Species Distribution",
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30.h),
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 45.r,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFFE25301),
                    value: 40,
                    title: '',
                    radius: 12.r,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF00D4F5),
                    value: 20,
                    title: '',
                    radius: 12.r,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF0D47A1),
                    value: 25,
                    title: '',
                    radius: 12.r,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF00E676),
                    value: 15,
                    title: '',
                    radius: 12.r,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25.h),
          _buildSpeciesLegend(),
        ],
      ),
    );
  }

  Widget _buildSpeciesLegend() {
    return Column(
      children: [
        Row(
          children: [
            _legendItem(const Color(0xFFE25301), "Others", "40%"),
            const Spacer(),
            _legendItem(const Color(0xFF00D4F5), "Tuna", "25%"),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _legendItem(const Color(0xFF0D47A1), "Snapper", "20%"),
            const Spacer(),
            _legendItem(const Color(0xFF00E676), "Grouper", "15%"),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(label, style: getTextStyle(fontSize: 12, color: Colors.white70)),
        SizedBox(width: 25.w),
        Text(
          percentage,
          style: getTextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue00F0FFColor, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            title,
            style: getTextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicZoneName(String name, {required double fontSize}) {
    final parts = name.split('-');
    if (parts.length >= 2) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: parts[0],
              style: getTextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: '-${parts.sublist(1).join("-")}',
              style: getTextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.blue00F0FFColor,
              ),
            ),
          ],
        ),
      );
    }
    return Text(
      name,
      style: getTextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

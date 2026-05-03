import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';

import '../controller/summary_details_controller.dart';

class SummaryTabWidget extends StatelessWidget {
  final bool isReportMainScreen;
  final SummaryController controller = Get.put(SummaryController());
  SummaryTabWidget({super.key, required this.isReportMainScreen});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final zone = controller.selectedZone.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddReportButton(),
          SizedBox(height: 12.h),
          if (isReportMainScreen == false) ...[
            _buildZoneHeader(zone),
            SizedBox(height: 15.h),
          ],
          _buildUpdateHeader(context),
          SizedBox(height: 25.h),
          _buildActivityOverview(zone),
          SizedBox(height: 18.h),
          _buildTopSpecies(),
          SizedBox(height: 12.h),

          _buildMarineConditions(),
          SizedBox(height: 12.h),
          _buildPatternIntelligence(),
          SizedBox(height: 16.h),
          _buildActivityTiming(),

          SizedBox(height: 16.h),
          if (isReportMainScreen == false) _buildSpeciesDistribution(),
          SizedBox(height: 30.h),
        ],
      );
    });
  }

  Widget _buildZoneHeader(MapZoneModel? zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDynamicZoneName(
          zone?.name ?? 'GOM-12',
          fontSize: 28,
          lineHeight: 20,
        ),
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

  Widget _buildUpdateHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PopupMenuButton<String>(
          offset: const Offset(0, 45),
          color: const Color(0xFF08131D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: const BorderSide(color: Color(0xFF2D3748)),
          ),
          onSelected: (String value) {
            controller.changeTimeRange(value);
          },
          itemBuilder: (BuildContext context) {
            return controller.timeRangeOptions.map((String option) {
              return PopupMenuItem<String>(
                value: option,
                child: Obx(() {
                  final isSelected =
                      controller.selectedTimeRange.value == option;
                  return Text(
                    option,
                    style: getTextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.blue00F0FFColor
                          : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }),
              );
            }).toList();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF08131D),
              border: Border.all(color: const Color(0xFF2D3748)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Image.asset(IconPath.calendarIcon, height: 14.h, width: 14.w),
                SizedBox(width: 10.w),
                Obx(
                  () => Text(
                    controller.selectedTimeRange.value,
                    style: getTextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      lineHeight: 9,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "Updated 2 min ago",
              style: getTextStyle(
                fontSize: 12,
                color: Color(0xFF018896),
                fontWeight: FontWeight.w500,
                lineHeight: 9,
              ),
            ),
            SizedBox(width: 5.w),
            Image.asset(IconPath.refreshIcon, height: 14.h, width: 14.w),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityOverview(MapZoneModel? zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(IconPath.activityIcon, "Activity Overview"),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _statCard(
                label: "LAST 24H",
                //"${zone?.reports ?? 8}",
                sub: "Reports",
                borderColor: AppColors.blue00F0FFColor,
                icon: IconPath.goalIcon,
                val: '8',
              ),
              _statCard(
                label: "SUCCESS",
                val: "78%",
                sub: "Hit Rate",
                borderColor: AppColors.orangeColor,
                icon: IconPath.redFish,
              ),
              _statCard(
                label: "Hot zone",
                val: "2",
                sub: "Active",
                borderColor: AppColors.blue00F0FFColor,
                icon: IconPath.curveArrowIcon,
              ),
              _statCard(
                label: "GROUPS",
                val: "3",
                sub: "Networks",
                borderColor: AppColors.orangeColor,
                icon: IconPath.redGroupsIcon,
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
        _sectionTitle(IconPath.airIcon, "Marine Conditions - Zone A-7"),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.blue0D2B43Color.withValues(alpha: 0.1),
                AppColors.orangeFF6B35Color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.blue153A56Color.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _marineItem(IconPath.airIcon, "12", "mph SE"),
                    _vDivider(),
                    _marineItem(IconPath.waveIcon, "2.5", "ft"),
                    _vDivider(),
                    _marineItem(IconPath.thermometerIcon, "78°", "F"),
                    _vDivider(),
                    _marineItem(IconPath.dropIcon, "1.2", "Rising"),
                    _vDivider(),
                    _marineItem(
                      IconPath.cloudIcon,
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
                    color: AppColors.blue00D4FFColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "View Full Forecast",
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A1628),
                      lineHeight: 10,
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
    String icon,
    String val,
    String unit, {
    bool isWeather = false,
  }) {
    return Column(
      children: [
        Image.asset(
          icon,
          color: AppColors.blue00F0FFColor,
          height: 20.h,
          width: 20.w,
        ),
        SizedBox(height: 4.h),
        Text(
          val,
          style: getTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            lineHeight: 14,
          ),
        ),
        Text(
          unit,
          style: getTextStyle(
            fontSize: 12,
            color: AppColors.grey8B95A5Color,
            lineHeight: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      color: AppColors.grey8B95A5Color.withValues(alpha: 0.3),
    );
  }

  Widget _statCard({
    required String label,
    required String val,
    required String sub,
    required Color borderColor,
    required String icon,
    Color? backgroundColor,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Color(0xFF09151F),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(icon, height: 14.h, width: 14.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: getTextStyle(
                        fontSize: 10,
                        color: AppColors.grey8B95A5Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              val,
              style: getTextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                lineHeight: 14,
              ),
            ),
            Text(
              sub.isNotEmpty ? sub : " ",
              style: getTextStyle(
                fontSize: 12,
                color: borderColor,
                lineHeight: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternIntelligence() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.blue00D4FFColor.withValues(alpha: 0.3),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.blue00D4FFColor.withValues(alpha: 0.1),
            AppColors.orangeFF6B35Color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PATTERN INTELLIGENCE",
            style: getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              lineHeight: 12,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _patternMetric(
                      "MOST COMMON DEPTH",
                      "120-180 ft",
                      AppColors.blue00D4FFColor,
                    ),
                    SizedBox(height: 16.h),
                    _patternMetric(
                      "TOP BAIT / LURE",
                      "Blue/White Ilander",
                      AppColors.blue00D4FFColor,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _patternMetric(
                      "MOST EFFECTIVE METHOD",
                      "Trolling",
                      AppColors.blue00D4FFColor,
                    ),
                    SizedBox(height: 16.h),
                    _patternMetric(
                      "STRIKE ZONE",
                      "Mid Column / Thermocline",
                      const Color(0xFFFF4842),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _patternMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 12,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w400,
            lineHeight: 9,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: valueColor,
            lineHeight: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTiming() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue0D2B43Color.withValues(alpha: 0.1),
            AppColors.orangeFF6B35Color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blue153A56Color.withValues(alpha: 0.3),
        ),
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
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  lineHeight: 12,
                ),
              ),
              Text(
                "24 Hours Ago",
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.blue00D4FFColor,
                  fontWeight: FontWeight.w400,
                  lineHeight: 9,
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
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.whiteColor,
                        lineHeight: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "6.00 AM - 10.00 AM",
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.blue00D4FFColor,
                        fontWeight: FontWeight.w400,
                        lineHeight: 9,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Most Effective\nTechnique",
                      style: getTextStyle(
                        fontSize: 12,
                        color: AppColors.whiteColor,
                        lineHeight: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue00D4FFColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
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
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue0D2B43Color.withValues(alpha: 0.1),
            AppColors.orangeFF6B35Color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.blue153A56Color.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOP SPECIES (LAST 24H)",
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              lineHeight: 12,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(speciesData.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Container(
                  height: 40.h,
                  width: 1,
                  color: AppColors.grey3A4B62Color.withValues(alpha: 0.3),
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
          IconPath.fishRealIcon,
          width: 24.w,
          height: 18.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 8.h),
        Text(
          count,
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            lineHeight: 9,
          ),
        ),
        Text(
          name,
          style: getTextStyle(
            fontSize: 12,
            color: Color(0xFF767E8A),
            lineHeight: 9,
            fontWeight: FontWeight.w400,
          ),
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
        border: Border.all(
          color: AppColors.blue153A56Color.withValues(alpha: 0.5),
        ),
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

  Widget _sectionTitle(String icon, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Image.asset(icon, height: 20.h, width: 20.w),
          SizedBox(width: 10.w),
          Text(
            title,
            style: getTextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              lineHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicZoneName(
    String name, {
    required double fontSize,
    required double lineHeight,
  }) {
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
                lineHeight: lineHeight,
              ),
            ),
            TextSpan(
              text: '-${parts.sublist(1).join("-")}',
              style: getTextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.blue00F0FFColor,
                lineHeight: lineHeight,
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

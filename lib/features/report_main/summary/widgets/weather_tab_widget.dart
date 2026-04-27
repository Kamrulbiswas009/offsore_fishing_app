import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';

import '../controller/summary_details_controller.dart';

class WeatherTabWidget extends GetView<SummaryController> {
  const WeatherTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFishingConditionsCard(),
        SizedBox(height: 16.h),
        _buildNowForecastToggle(),
        SizedBox(height: 16.h),
        Obx(() {
          final isForecast = controller.selectedWeatherType.value == 'Forecast';
          if (isForecast) {
            return _buildForecastContent();
          }
          return _buildNowContent();
        }),
      ],
    );
  }

  // ── "Now" full content ──────────────────────────────────────────────────────
  Widget _buildNowContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        _buildActivityOverview(),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.blue0D2B43Color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.blue153A56Color.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastUpdated(),
              SizedBox(height: 20.h),
              _buildMarineDetails(),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        _buildSunMoon(),
        SizedBox(height: 20.h),
        _buildTideCurrents(),
        SizedBox(height: 30.h),
      ],
    );
  }

  // ── "Forecast" full content ─────────────────────────────────────────────────
  Widget _buildForecastContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLastUpdated(),
        SizedBox(height: 14.h),
        _buildSelectDay(),
        SizedBox(height: 26.h),
        _buildTimePeriodToggle(),
        SizedBox(height: 16.h),
        _buildForecastCard(),
        SizedBox(height: 20.h),
      ],
    );
  }

  // ── Fishing Conditions ──────────────────────────────────────────────────────
  Widget _buildFishingConditionsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Color(0xFF00D4FF),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal0C98AFColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Excellent',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fishing Conditions',
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Ideal conditions for offshore fishing with moderate seas and favorable winds',
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.grey8B95A5Color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Now / Forecast toggle ───────────────────────────────────────────────────
  Widget _buildNowForecastToggle() {
    return Obx(() {
      final isNow = controller.selectedWeatherType.value == 'Now';
      return Row(
        children: ['Now', 'Forecast'].map((label) {
          final selected = (label == 'Now') == isNow;
          return Expanded(
            flex: selected ? 2 : 1,
            child: GestureDetector(
              onTap: () => controller.selectedWeatherType.value = label,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 34.h,
                margin: EdgeInsets.only(right: label == 'Now' ? 12.w : 0),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.teal0C98AFColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: selected
                        ? AppColors.blue00F0FFColor
                        : AppColors.grey3A4B62Color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    lineHeight: 24,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ── Activity Overview ───────────────────────────────────────────────────────
  Widget _buildActivityOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(IconPath.activityIcon, width: 18.w, height: 18.h),
            SizedBox(width: 6.w),
            Text(
              'Activity Overview',
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                lineHeight: 27,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.75,
          children: [
            _overviewItem(
              Icons.air,
              '12 mph',
              'NE',
              label: 'Wind',
              iconColor: AppColors.orangeColor,
              borderColor: AppColors.blue00F0FFColor,
              subtitleColor: AppColors.blue00F0FFColor,
            ),
            _overviewItem(
              Icons.waves,
              '2-3 ft',
              'Moderate',
              label: 'Waves',
              iconColor: AppColors.blue00F0FFColor,
              borderColor: AppColors.orangeColor,
              subtitleColor: AppColors.orangeColor,
            ),
            _overviewItem(
              Icons.thermostat,
              '78°F',
              'Stable',
              label: 'Water Temp',
              iconColor: AppColors.orangeColor,
              borderColor: AppColors.blue00F0FFColor,
              subtitleColor: AppColors.blue00F0FFColor,
            ),
            _overviewItem(
              Icons.water_drop_outlined,
              '72%',
              'Normal',
              label: 'Humidity',
              iconColor: AppColors.blue00F0FFColor,
              borderColor: AppColors.orangeColor,
              subtitleColor: AppColors.orangeColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _overviewItem(
    IconData icon,
    String value,
    String subtitle, {
    required String label,
    required Color iconColor,
    required Color borderColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 12.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 9,
                    color: AppColors.grey8B95A5Color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              fontSize: 10,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(IconData icon) {
    if (icon == Icons.air) return 'Wind';
    if (icon == Icons.waves) return 'Waves';
    if (icon == Icons.thermostat) return 'Water Temp';
    return 'Humidity';
  }

  Widget _divider() {
    return Container(
      height: 40.h,
      width: 1,
      color: AppColors.grey3A4B62Color.withOpacity(0.5),
    );
  }

  // ── Last Updated ────────────────────────────────────────────────────────────
  Widget _buildLastUpdated() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.blue00F0FFColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14.sp,
                color: AppColors.blue00F0FFColor,
              ),
              SizedBox(width: 8.w),
              Text(
                'LAST UPDATED',
                style: getTextStyle(
                  fontSize: 10,
                  color: AppColors.grey8B95A5Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'about 2 hours ago',
            style: getTextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              lineHeight: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── Marine Details ──────────────────────────────────────────────────────────
  Widget _buildMarineDetails() {
    final items = <_MarineItem>[
      _MarineItem(
        icon: Icons.explore,
        iconColor: AppColors.blue00F0FFColor,
        label: 'Swell Direction',
        value: 'East',
      ),
      _MarineItem(
        icon: Icons.waves,
        iconColor: const Color(0xFFE25301),
        label: 'Swell Period',
        value: '8 seconds',
      ),
      _MarineItem(
        icon: Icons.thermostat,
        iconColor: AppColors.blue00F0FFColor,
        label: 'Air Temperature',
        value: '82°F',
      ),
      _MarineItem(
        icon: Icons.cloud_outlined,
        iconColor: const Color(0xFFE25301),
        label: 'Cloud Cover',
        value: '25%',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marine Details',
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            lineHeight: 26,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        ...items.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.blue0D2B43Color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: item.iconColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: item.iconColor, size: 18.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item.label,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      lineHeight: 20,
                      color: AppColors.grey8B95A5Color,
                    ),
                  ),
                ),
                Text(
                  item.value,
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    lineHeight: 20,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // ── Sun & Moon ──────────────────────────────────────────────────────────────
  Widget _buildSunMoon() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sun & Moon',
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              lineHeight: 28,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.5,
            children: [
              _sunMoonItem(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFFAA00),
                label: 'Sunrise',
                value: '6:42 AM',
              ),
              _sunMoonItem(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFFF6B35),
                label: 'Sunset',
                value: '7:28 PM',
              ),
              _sunMoonItem(
                icon: Icons.nightlight_outlined,
                iconColor: AppColors.blue00F0FFColor,
                label: 'Moonrise',
                value: '8:15 PM',
              ),
              _sunMoonItem(
                icon: Icons.nightlight_outlined,
                iconColor: AppColors.blue00F0FFColor,
                label: 'Moon Phase',
                value: 'Waxing',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sunMoonItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  lineHeight: 16,
                  color: AppColors.grey8B95A5Color,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: getTextStyle(
              fontSize: 18,
              lineHeight: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tide Currents ───────────────────────────────────────────────────────────
  Widget _buildTideCurrents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tide Currents',
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.blue0D2B43Color,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: AppColors.blue153A56Color.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              _buildTideChart(),
              SizedBox(height: 16.h),
              _buildTideEntry(
                icon: Icons.arrow_downward,
                label: 'Low Tide',
                time: '5:32 AM',
                value: '0.8 ft',
                isCurrent: false,
              ),
              Divider(
                height: 20.h,
                color: AppColors.blue153A56Color.withValues(alpha: 0.5),
              ),
              _buildTideEntry(
                icon: Icons.arrow_upward,
                label: 'High Tide',
                time: '11:45 AM',
                value: '4.2 ft',
                isCurrent: true,
              ),
              Divider(
                height: 20.h,
                color: AppColors.blue153A56Color.withValues(alpha: 0.5),
              ),
              _buildTideEntry(
                icon: Icons.arrow_downward,
                label: 'Low Tide',
                time: '6:18 PM',
                value: '1.1 ft',
                isCurrent: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTideChart() {
    return Column(
      children: [
        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Midnight', '6:00 AM', 'Noon', '6:00 PM'].map((t) {
            return Text(
              t,
              style: getTextStyle(
                fontSize: 9,
                color: AppColors.grey8B95A5Color,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          height: 90.h,
          child: CustomPaint(painter: _TideChartPainter(), child: Container()),
        ),
      ],
    );
  }

  Widget _buildTideEntry({
    required IconData icon,
    required String label,
    required String time,
    required String value,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.blue153A56Color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.blue00F0FFColor, size: 16.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                time,
                style: getTextStyle(
                  fontSize: 11,
                  color: AppColors.grey8B95A5Color,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isCurrent)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.teal0C98AFColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.blue00F0FFColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Current',
                  style: getTextStyle(
                    fontSize: 9,
                    color: AppColors.blue00F0FFColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Select Day ──────────────────────────────────────────────────────────────
  Widget _buildSelectDay() {
    final days = controller.days;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Day',
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() {
            return Row(
              children: days.map((day) {
                final isSelected = day == controller.selectedDay.value;
                return GestureDetector(
                  onTap: () => controller.selectedDay.value = day,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF00D4FF)
                          : AppColors.blue0D2B43Color,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blue00F0FFColor
                            : AppColors.blue153A56Color.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      day,
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        SizedBox(height: 15.h),
        Center(
          child: Text(
            'TODAY - SAT 18',
            style: getTextStyle(
              fontSize: 11,
              color: AppColors.grey8B95A5Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Time Period Toggle ──────────────────────────────────────────────────────
  Widget _buildTimePeriodToggle() {
    final periods = controller.timePeriods;
    return Obx(() {
      return Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.blue0D2B43Color,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.blue153A56Color.withOpacity(0.5)),
        ),
        child: Row(
          children: periods.map((period) {
            final isSelected = period == controller.selectedTimePeriod.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTimePeriod.value = period,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.teal0C98AFColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    period,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // ── Forecast Card (with floating + button) ──────────────────────────────────
  Widget _buildForecastCard() {
    return Obx(() {
      final period = controller.selectedTimePeriod.value;
      final data = _forecastDataFor(period);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Main card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.blue0D2B43Color,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.blue153A56Color.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: AppColors.blue153A56Color.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data['icon'] as IconData,
                            color: data['iconColor'] as Color,
                            size: 22.sp,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              period,
                              style: getTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              data['time'] as String,
                              style: getTextStyle(
                                fontSize: 12,
                                color: AppColors.grey8B95A5Color,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green10B981Color,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            data['badge'] as String,
                            style: getTextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _forecastStat(
                          Icons.air,
                          data['wind'] as String,
                          'Wind',
                          'mph',
                        ),
                        _forecastStat(
                          Icons.waves,
                          data['seas'] as String,
                          'Seas',
                          'ft',
                        ),
                        _forecastStat(
                          Icons.cloud_outlined,
                          data['sky'] as String,
                          'Sky',
                          '% cloudy',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              // Description card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.blue0D2B43Color,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.blue153A56Color.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  data['description'] as String,
                  style: getTextStyle(
                    fontSize: 13,
                    color: AppColors.greyC8D0DBColor,
                  ),
                ),
              ),
            ],
          ),
          // Floating "+" button
          Positioned(
            right: 0,
            bottom: 62.h,
            child: GestureDetector(
              onTap: () => Get.to(ReportCatchStep1Screen()),
              child: Container(
                width: 46.w,
                height: 46.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFE25301)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 24.sp),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _forecastStat(IconData icon, String value, String label, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.grey8B95A5Color, size: 13.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: getTextStyle(
                fontSize: 10,
                color: AppColors.grey8B95A5Color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: getTextStyle(
            fontSize: 22,
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

  Map<String, dynamic> _forecastDataFor(String period) {
    switch (period) {
      case 'Afternoon':
        return {
          'icon': Icons.wb_sunny,
          'iconColor': const Color(0xFFFFAA00),
          'time': '12:00 PM - 6:00 PM',
          'badge': 'Fair',
          'wind': '14',
          'seas': '2.5',
          'sky': '35',
          'description':
              'Moderate winds picking up in the afternoon. Seas building slightly but still fishable.',
        };
      case 'Evening':
        return {
          'icon': Icons.nightlight_round,
          'iconColor': AppColors.blue00F0FFColor,
          'time': '6:00 PM - 10:00 PM',
          'badge': 'Good',
          'wind': '8',
          'seas': '1.5',
          'sky': '15',
          'description':
              'Calm evening conditions. Light winds and minimal swell — great for inshore fishing.',
        };
      default: // Morning
        return {
          'icon': Icons.wb_sunny_outlined,
          'iconColor': const Color(0xFFFFAA00),
          'time': '6:00 AM - 12:00 PM',
          'badge': 'Good',
          'wind': '10',
          'seas': '2.0',
          'sky': '20',
          'description':
              'Calm winds and smaller seas. Great window to get offshore.',
        };
    }
  }
}

// ── Custom tide chart painter ─────────────────────────────────────────────────
class _TideChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background guide line
    final guidePaint = Paint()
      ..color = const Color(0xFF1E3A50)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      final y = h * i / 4;
      canvas.drawLine(Offset(0, y), Offset(w, y), guidePaint);
    }

    // Tide curve – a smooth wave approximating the chart in the design
    final path = Path();
    // Low (midnight) → high (morning) → lower (noon) → high again (evening)
    final points = [
      Offset(0, h * 0.72), // midnight – low
      Offset(w * 0.10, h * 0.70),
      Offset(w * 0.22, h * 0.30), // rising toward first high
      Offset(w * 0.33, h * 0.20), // morning high (~6AM)
      Offset(w * 0.44, h * 0.28),
      Offset(w * 0.50, h * 0.40), // noon – moderate
      Offset(w * 0.60, h * 0.30),
      Offset(w * 0.72, h * 0.22), // afternoon high
      Offset(w * 0.85, h * 0.45),
      Offset(w, h * 0.65), // late evening – lowering
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;
      _catmullRomSegment(canvas, path, p0, p1, p2, p3);
    }

    // Filled area under the curve
    final fillPath = Path.from(path);
    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00F0FF).withValues(alpha: 0.25),
          const Color(0xFF00F0FF).withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // Dotted vertical line at high tide (~33% of width = 6AM)
    final dotX = w * 0.33;
    final dottedPaint = Paint()
      ..color = const Color(0xFFE25301)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashH = 5.0;
    double startY = 0;
    while (startY < h) {
      canvas.drawLine(
        Offset(dotX, startY),
        Offset(dotX, (startY + dashH).clamp(0, h)),
        dottedPaint,
      );
      startY += dashH * 2;
    }

    // Dot at the intersection
    canvas.drawCircle(
      Offset(dotX, h * 0.20),
      5,
      Paint()..color = const Color(0xFFE25301),
    );
    canvas.drawCircle(Offset(dotX, h * 0.20), 3, Paint()..color = Colors.white);
  }

  void _catmullRomSegment(
    Canvas canvas,
    Path path,
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
  ) {
    const double tension = 0.5;
    final cp1x = p1.dx + (p2.dx - p0.dx) * tension / 3;
    final cp1y = p1.dy + (p2.dy - p0.dy) * tension / 3;
    final cp2x = p2.dx - (p3.dx - p1.dx) * tension / 3;
    final cp2y = p2.dy - (p3.dy - p1.dy) * tension / 3;
    path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Data class ────────────────────────────────────────────────────────────────
class _MarineItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MarineItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

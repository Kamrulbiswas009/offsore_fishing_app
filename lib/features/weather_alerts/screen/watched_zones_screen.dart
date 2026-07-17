// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/weather_alerts/controller/weather_alert_controller.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';
import 'package:paytonpieper/features/weather_alerts/model/watched_zone_model.dart';
import 'package:paytonpieper/features/weather_alerts/model/bite_watch_model.dart';
import 'package:paytonpieper/features/weather_alerts/widgets/zone_watch_settings_sheet.dart';
import 'package:paytonpieper/features/weather_alerts/widgets/bite_watch_settings_sheet.dart';
import 'package:intl/intl.dart';

/// Full-screen list of all watched zones, managing both Weather Alerts (local)
/// and Bite Activity Alerts (backend API integration).
class WatchedZonesScreen extends StatelessWidget {
  const WatchedZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherCtrl = Get.find<WeatherAlertController>();
    final biteCtrl = Get.find<BiteWatchController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(weatherCtrl, biteCtrl),
            _buildSubHeader(),
            Expanded(
              child: Obx(() {
                final weatherZones = weatherCtrl.watchedZones;
                final biteZones = biteCtrl.watchedZones;
                final allZoneIds = {
                  ...weatherZones.map((z) => z.zoneId),
                  ...biteZones.map((z) => z.zoneId),
                }.toList();

                if (allZoneIds.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildZoneList(allZoneIds, weatherCtrl, biteCtrl);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(WeatherAlertController weatherCtrl, BiteWatchController biteCtrl) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.blue0D2B43Color,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.grey516173Color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watched Zones',
                  style: getTextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(() {
                  final weatherCount = weatherCtrl.watchedZones.length;
                  final biteCount = biteCtrl.watchedZones.length;
                  return Text(
                    '$weatherCount weather / $biteCount bite monitors active',
                    style: getTextStyle(
                      fontSize: 12,
                      color: AppColors.grey8B95A5Color,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.tealColor117A88.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.tealColor117A88.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: AppColors.teal0C98AFColor,
                  size: 14.sp,
                ),
                SizedBox(width: 5.w),
                Text(
                  'Live',
                  style: getTextStyle(
                    fontSize: 12,
                    color: AppColors.teal0C98AFColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.tealColor117A88.withOpacity(0.12),
            AppColors.blue0D2B43Color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.tealColor117A88.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.teal0C98AFColor,
            size: 16.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Weather alerts update locally. Bite alerts are synced with the server and fire upon recent report activity spikes.',
              style: getTextStyle(
                fontSize: 11,
                color: AppColors.grey8B95A5Color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Zone List ──────────────────────────────────────────────────────────────

  Widget _buildZoneList(
    List<String> zoneIds,
    WeatherAlertController weatherCtrl,
    BiteWatchController biteCtrl,
  ) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: zoneIds.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, index) {
        final zoneId = zoneIds[index];
        final weatherConfig = weatherCtrl.configFor(zoneId);
        final biteConfig = biteCtrl.getWatchFor(zoneId);
        
        return _UnifiedZoneCard(
          zoneId: zoneId,
          weatherConfig: weatherConfig,
          biteConfig: biteConfig,
          weatherCtrl: weatherCtrl,
          biteCtrl: biteCtrl,
        );
      },
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.tealColor117A88.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48.sp,
                color: AppColors.teal0C98AFColor.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Watched Zones',
              style: getTextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select any zone on the map, then enable weather or bite activity monitoring.',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 13,
                color: AppColors.grey8B95A5Color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 28.h),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text('Browse Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealColor117A88,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Unified Zone Card Widget ────────────────────────────────────────────────

class _UnifiedZoneCard extends StatelessWidget {
  const _UnifiedZoneCard({
    required this.zoneId,
    this.weatherConfig,
    this.biteConfig,
    required this.weatherCtrl,
    required this.biteCtrl,
  });

  final String zoneId;
  final WatchedZoneConfig? weatherConfig;
  final BiteWatchModel? biteConfig;
  final WeatherAlertController weatherCtrl;
  final BiteWatchController biteCtrl;

  @override
  Widget build(BuildContext context) {
    final hasWeather = weatherConfig != null;
    final hasBite = biteConfig != null;

    final weatherSnapshot = weatherCtrl.lastSnapshotFor(zoneId);
    final biteLastNotified = biteConfig?.lastNotifiedAt;

    String lastAlertText = 'No alerts sent yet';
    if (weatherSnapshot != null && biteLastNotified != null) {
      final latest = weatherSnapshot.lastAlertAt.isAfter(biteLastNotified)
          ? weatherSnapshot.lastAlertAt
          : biteLastNotified;
      lastAlertText = 'Last alert: ${_formatTime(latest)}';
    } else if (weatherSnapshot != null) {
      lastAlertText = 'Last alert (weather): ${_formatTime(weatherSnapshot.lastAlertAt)}';
    } else if (biteLastNotified != null) {
      lastAlertText = 'Last alert (bite): ${_formatTime(biteLastNotified)}';
    }

    final isWeatherEnabled = weatherConfig?.alertsEnabled ?? false;
    final isBiteEnabled = biteConfig?.watchBiteActivity ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (isWeatherEnabled || isBiteEnabled)
              ? AppColors.tealColor117A88.withOpacity(0.35)
              : AppColors.grey516173Color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone Name Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherConfig?.zoneName ?? biteConfig?.displayLabel ?? zoneId,
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        lastAlertText,
                        style: getTextStyle(
                          fontSize: 11,
                          color: AppColors.grey8B95A5Color,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _onDeletePressed,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppColors.redDA605CColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.redDA605CColor,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: AppColors.grey516173Color.withOpacity(0.15), height: 16.h),

            // --- Weather Section ---
            if (hasWeather) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isWeatherEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: isWeatherEnabled ? AppColors.teal0C98AFColor : AppColors.grey516173Color,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Weather Alerts',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isWeatherEnabled,
                    onChanged: (enabled) =>
                        weatherCtrl.toggleAlerts(zoneId, enabled: enabled),
                    activeColor: AppColors.teal0C98AFColor,
                    activeTrackColor: AppColors.tealColor117A88.withOpacity(0.4),
                    inactiveThumbColor: AppColors.grey516173Color,
                    inactiveTrackColor: AppColors.grey516173Color.withOpacity(0.15),
                  ),
                ],
              ),
              if (isWeatherEnabled) ...[
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    _ThresholdPill(
                      icon: Icons.waves_rounded,
                      color: const Color(0xFF00D4FF),
                      label: '>${weatherConfig!.waveHeightThresholdFt.toStringAsFixed(0)} ft',
                    ),
                    _ThresholdPill(
                      icon: Icons.air_rounded,
                      color: const Color(0xFF10B981),
                      label: '>${weatherConfig!.windSpeedThresholdMph.toStringAsFixed(0)} mph',
                    ),
                    _ThresholdPill(
                      icon: Icons.thermostat_rounded,
                      color: const Color(0xFFE25301),
                      label: '±${weatherConfig!.waterTempChangeDeltaF.toStringAsFixed(0)}°F',
                    ),
                  ],
                ),
              ],
              SizedBox(height: 6.h),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => ZoneWatchSettingsSheet.show(
                      config: weatherConfig!,
                      isEditing: true,
                    ),
                    icon: Icon(Icons.tune_rounded, size: 13.sp),
                    label: const Text('Edit Weather Thresholds'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.teal0C98AFColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: getTextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],

            // --- Bite Activity Section ---
            if (hasBite) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isBiteEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: isBiteEnabled ? const Color(0xFFFF6D00) : AppColors.grey516173Color,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Bite Activity Alerts',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isBiteEnabled,
                    onChanged: (enabled) =>
                        biteCtrl.updateWatchSettings(zoneId, watchBiteActivity: enabled),
                    activeColor: const Color(0xFFFF6D00),
                    activeTrackColor: const Color(0xFFFF6D00).withOpacity(0.4),
                    inactiveThumbColor: AppColors.grey516173Color,
                    inactiveTrackColor: AppColors.grey516173Color.withOpacity(0.15),
                  ),
                ],
              ),
              if (isBiteEnabled) ...[
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    _ThresholdPill(
                      icon: Icons.phishing,
                      color: const Color(0xFFFF6D00),
                      label: '≥${biteConfig!.biteThreshold} reports',
                    ),
                    _ThresholdPill(
                      icon: Icons.calendar_month_outlined,
                      color: const Color(0xFF00D4FF),
                      label: 'within ${biteConfig!.biteThresholdDays} days',
                    ),
                  ],
                ),
              ],
              SizedBox(height: 6.h),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => BiteWatchSettingsSheet.show(
                      zoneId: zoneId,
                      config: biteConfig,
                      isEditing: true,
                    ),
                    icon: Icon(Icons.tune_rounded, size: 13.sp),
                    label: const Text('Edit Bite Thresholds'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6D00),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: getTextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  void _onDeletePressed() {
    final list = <Widget>[];
    if (weatherConfig != null) {
      list.add(
        ListTile(
          leading: const Icon(Icons.waves_rounded, color: AppColors.teal0C98AFColor),
          title: const Text(
            'Remove Weather Watch',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Get.back();
            weatherCtrl.removeZone(zoneId);
          },
        ),
      );
    }
    if (biteConfig != null) {
      list.add(
        ListTile(
          leading: const Icon(Icons.phishing, color: Color(0xFFFF6D00)),
          title: const Text(
            'Remove Bite Activity Watch',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            Get.back();
            biteCtrl.unwatchZone(zoneId);
          },
        ),
      );
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: AppColors.tealColor117A88.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Remove Watch Settings',
              style: getTextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12.h),
            ...list,
            SizedBox(height: 8.h),
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.grey516173Color.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final diff = DateTime.now().difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(local);
  }
}

class _ThresholdPill extends StatelessWidget {
  const _ThresholdPill({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

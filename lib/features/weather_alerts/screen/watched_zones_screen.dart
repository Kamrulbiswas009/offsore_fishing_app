// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/weather_alerts/controller/weather_alert_controller.dart';
import 'package:paytonpieper/features/weather_alerts/model/watched_zone_model.dart';
import 'package:paytonpieper/features/weather_alerts/widgets/zone_watch_settings_sheet.dart';
import 'package:intl/intl.dart';

/// Full-screen list of all watched zones with alert management.
class WatchedZonesScreen extends GetView<WeatherAlertController> {
  const WatchedZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildSubHeader(),
            Expanded(
              child: Obx(() {
                if (controller.watchedZones.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildZoneList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
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
                Obx(() => Text(
                  '${controller.watchedZones.length} zone${controller.watchedZones.length == 1 ? '' : 's'} monitored',
                  style: getTextStyle(
                    fontSize: 12,
                    color: AppColors.grey8B95A5Color,
                    fontWeight: FontWeight.w400,
                  ),
                )),
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
              'Alerts fire when conditions meaningfully improve or deteriorate. Identical conditions are suppressed for 4 hours.',
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

  Widget _buildZoneList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: controller.watchedZones.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, index) {
        final zone = controller.watchedZones[index];
        return _ZoneCard(zone: zone, controller: controller);
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
              'Go to the Weather tab on any zone and tap the bell icon to start watching.',
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
              label: const Text('Browse Zones'),
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

// ── Zone Card Widget ─────────────────────────────────────────────────────────

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.zone, required this.controller});

  final WatchedZoneConfig zone;
  final WeatherAlertController controller;

  @override
  Widget build(BuildContext context) {
    final snapshot = controller.lastSnapshotFor(zone.zoneId);
    final lastAlertText = snapshot != null
        ? 'Last alert: ${_formatTime(snapshot.lastAlertAt)}'
        : 'No alerts sent yet';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: zone.alertsEnabled
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
            // ── Row 1: Zone name + toggle ──
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: zone.alertsEnabled
                        ? AppColors.tealColor117A88.withOpacity(0.15)
                        : AppColors.grey516173Color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    zone.alertsEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: zone.alertsEnabled
                        ? AppColors.teal0C98AFColor
                        : AppColors.grey516173Color,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.zoneName,
                        style: getTextStyle(
                          fontSize: 14,
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
                Switch(
                  value: zone.alertsEnabled,
                  onChanged: (enabled) =>
                      controller.toggleAlerts(zone.zoneId, enabled: enabled),
                  activeColor: AppColors.teal0C98AFColor,
                  activeTrackColor: AppColors.tealColor117A88.withOpacity(0.4),
                  inactiveThumbColor: AppColors.grey516173Color,
                  inactiveTrackColor:
                      AppColors.grey516173Color.withOpacity(0.15),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // ── Row 2: Threshold pills ──
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                _ThresholdPill(
                  icon: Icons.waves_rounded,
                  color: const Color(0xFF00D4FF),
                  label: '>${zone.waveHeightThresholdFt.toStringAsFixed(0)} ft',
                ),
                _ThresholdPill(
                  icon: Icons.air_rounded,
                  color: const Color(0xFF10B981),
                  label: '>${zone.windSpeedThresholdMph.toStringAsFixed(0)} mph',
                ),
                _ThresholdPill(
                  icon: Icons.thermostat_rounded,
                  color: const Color(0xFFE25301),
                  label: '±${zone.waterTempChangeDeltaF.toStringAsFixed(0)}°F',
                ),
                if (zone.alertOnThunderstorm)
                  _ThresholdPill(
                    icon: Icons.thunderstorm_rounded,
                    color: Colors.amber,
                    label: 'Storm Alert',
                  ),
                if (zone.alertOnRain)
                  _ThresholdPill(
                    icon: Icons.umbrella_rounded,
                    color: Colors.lightBlue,
                    label: 'Rain Alert',
                  ),
                if (zone.alertOnGoodSunny)
                  _ThresholdPill(
                    icon: Icons.wb_sunny_rounded,
                    color: Colors.orange,
                    label: 'Sunny Alert',
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // ── Row 3: Action buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ZoneWatchSettingsSheet.show(
                      config: zone,
                      isEditing: true,
                    ),
                    icon: Icon(Icons.tune_rounded, size: 14.sp),
                    label: const Text('Edit Thresholds'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal0C98AFColor,
                      side: BorderSide(
                        color: AppColors.tealColor117A88.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      textStyle: getTextStyle(
                        fontSize: 12,
                        color: AppColors.teal0C98AFColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  onPressed: () => _confirmRemove(zone),
                  icon: Icon(Icons.delete_outline_rounded, size: 14.sp),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.redDA605CColor,
                    side: BorderSide(
                      color: AppColors.redDA605CColor.withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    textStyle: getTextStyle(
                      fontSize: 12,
                      color: AppColors.redDA605CColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(WatchedZoneConfig z) {
    Get.defaultDialog(
      title: 'Remove Zone',
      middleText: 'Stop watching ${z.zoneName}? You will no longer receive weather alerts for this zone.',
      textConfirm: 'Remove',
      textCancel: 'Keep',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.redDA605CColor,
      cancelTextColor: Colors.white,
      backgroundColor: AppColors.blue0D2B43Color,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      middleTextStyle: const TextStyle(color: Color(0xFF8B95A5)),
      onConfirm: () {
        Get.back();
        controller.removeZone(z.zoneId);
        Get.snackbar(
          'Zone Removed',
          '${z.zoneName} has been removed from your watch list.',
          backgroundColor: const Color(0xFF3F2B27),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      },
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

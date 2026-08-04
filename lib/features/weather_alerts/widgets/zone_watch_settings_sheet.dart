// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/weather_alerts/controller/weather_alert_controller.dart';
import 'package:paytonpieper/features/weather_alerts/model/watched_zone_model.dart';

/// A premium bottom sheet that lets the user configure watch settings for a zone.
/// Fully responsive — handles small screens and keyboard insets without overflow.
class ZoneWatchSettingsSheet extends StatefulWidget {
  final WatchedZoneConfig config;
  final bool isEditing;

  const ZoneWatchSettingsSheet({
    super.key,
    required this.config,
    this.isEditing = false,
  });

  /// Opens the bottom sheet.
  static Future<void> show({
    required WatchedZoneConfig config,
    bool isEditing = false,
  }) {
    return Get.bottomSheet(
      ZoneWatchSettingsSheet(config: config, isEditing: isEditing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  State<ZoneWatchSettingsSheet> createState() => _ZoneWatchSettingsSheetState();
}

class _ZoneWatchSettingsSheetState extends State<ZoneWatchSettingsSheet>
    with SingleTickerProviderStateMixin {
  late bool _alertsEnabled;
  late double _waveThreshold;
  late double _windThreshold;
  late double _tempDelta;
  late bool _alertOnThunderstorm;
  late bool _alertOnRain;
  late bool _alertOnGoodSunny;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _alertsEnabled = widget.config.alertsEnabled;
    _waveThreshold = widget.config.waveHeightThresholdFt;
    _windThreshold = widget.config.windSpeedThresholdMph;
    _tempDelta = widget.config.waterTempChangeDeltaF;
    _alertOnThunderstorm = widget.config.alertOnThunderstorm;
    _alertOnRain = widget.config.alertOnRain;
    _alertOnGoodSunny = widget.config.alertOnGoodSunny;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reserve at most 90% of the screen height for the sheet so it never
    // overflows on short devices.
    final maxHeight = MediaQuery.of(context).size.height * 0.90;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        // Use a minimum top margin that respects small screens.
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24),
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarkColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: AppColors.tealColor117A88.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Fixed header (handle + title + toggle) ───────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(),
                    SizedBox(height: 18.h),
                    _buildHeader(),
                    SizedBox(height: 16.h),
                    _buildAlertToggle(),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),

              // ── Scrollable threshold sliders ─────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    8.h,
                    20.w,
                    bottomInset + 8.h,
                  ),
                  child: AnimatedOpacity(
                    opacity: _alertsEnabled ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !_alertsEnabled,
                      child: Column(
                        children: [
                          _buildThresholdSection(
                            icon: Icons.waves_rounded,
                            iconColor: const Color(0xFF00D4FF),
                            label: 'Wave Height Alert',
                            description: 'Alert when waves are less than',
                            value: _waveThreshold,
                            min: 1.0,
                            max: 12.0,
                            divisions: 22,
                            unit: 'ft',
                            onChanged: (v) =>
                                setState(() => _waveThreshold = v),
                          ),
                          SizedBox(height: 14.h),
                          _buildThresholdSection(
                            icon: Icons.air_rounded,
                            iconColor: const Color(0xFF10B981),
                            label: 'Wind Speed Alert',
                            description: 'Alert when wind speed is less than',
                            value: _windThreshold,
                            min: 5.0,
                            max: 50.0,
                            divisions: 18,
                            unit: 'mph',
                            onChanged: (v) =>
                                setState(() => _windThreshold = v),
                          ),
                          SizedBox(height: 14.h),
                          _buildThresholdSection(
                            icon: Icons.thermostat_rounded,
                            iconColor: const Color(0xFFE25301),
                            label: 'Water Temp Change',
                            description: 'Alert on shift greater than',
                            value: _tempDelta,
                            min: 1.0,
                            max: 15.0,
                            divisions: 28,
                            unit: '°F',
                            onChanged: (v) => setState(() => _tempDelta = v),
                          ),
                          SizedBox(height: 14.h),
                          _buildConditionToggles(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Fixed action buttons ─────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildHandle() => Center(
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.grey516173Color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      );

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Bell icon box — fixed size, never shrinks
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.tealColor117A88.withOpacity(0.3),
                AppColors.teal0C98AFColor.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.tealColor117A88.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.notifications_active_rounded,
            color: AppColors.teal0C98AFColor,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        // Text column — takes all remaining width
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Edit Alert Settings' : 'Watch This Zone',
                style: getTextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                widget.config.zoneName,
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.grey8B95A5Color,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _alertsEnabled
              ? AppColors.tealColor117A88.withOpacity(0.5)
              : AppColors.grey516173Color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _alertsEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: _alertsEnabled
                ? AppColors.teal0C98AFColor
                : AppColors.grey516173Color,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          // Text block — Expanded to absorb available space before the switch
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Alerts',
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _alertsEnabled
                      ? 'Notify me when conditions change'
                      : 'Alerts paused for this zone',
                  style: getTextStyle(
                    fontSize: 11,
                    color: AppColors.grey8B95A5Color,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Switch — intrinsic size, never causes overflow
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _alertsEnabled,
              onChanged: (v) => setState(() => _alertsEnabled = v),
              activeColor: AppColors.teal0C98AFColor,
              activeTrackColor: AppColors.tealColor117A88.withOpacity(0.4),
              inactiveThumbColor: AppColors.grey516173Color,
              inactiveTrackColor: AppColors.grey516173Color.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    final valueLabel =
        '${value.toStringAsFixed(value == value.floorToDouble() ? 0 : 1)} $unit';

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.grey516173Color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label row ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon chip — fixed size
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: iconColor, size: 15.sp),
              ),
              SizedBox(width: 10.w),
              // Label + description — Expanded, never overflows
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      description,
                      style: getTextStyle(
                        fontSize: 11,
                        color: AppColors.grey8B95A5Color,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Value badge — fixed intrinsic width, no flex fighting
              Container(
                constraints: BoxConstraints(minWidth: 52.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: iconColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  valueLabel,
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // ── Slider with Increment/Decrement Buttons ─────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final step = (max - min) / divisions;
                  final newVal = (value - step).clamp(min, max);
                  // Parse to 1 decimal place to prevent floating-point representation bugs
                  final roundedVal = double.parse(newVal.toStringAsFixed(1));
                  onChanged(roundedVal);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: iconColor.withOpacity(0.8),
                    size: 20.sp,
                  ),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: iconColor,
                    inactiveTrackColor: iconColor.withOpacity(0.15),
                    thumbColor: iconColor,
                    overlayColor: iconColor.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    onChanged: onChanged,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final step = (max - min) / divisions;
                  final newVal = (value + step).clamp(min, max);
                  final roundedVal = double.parse(newVal.toStringAsFixed(1));
                  onChanged(roundedVal);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    color: iconColor.withOpacity(0.8),
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),

          // ── Min/Max labels ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${min.toInt()} $unit',
                  style: getTextStyle(
                    fontSize: 10,
                    color: AppColors.grey516173Color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${max.toInt()} $unit',
                  style: getTextStyle(
                    fontSize: 10,
                    color: AppColors.grey516173Color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionToggles() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.grey516173Color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Condition Alerts',
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _buildToggleItem(
            icon: Icons.thunderstorm_rounded,
            iconColor: Colors.amber,
            label: 'Thunderstorm Alert',
            value: _alertOnThunderstorm,
            onChanged: (val) => setState(() => _alertOnThunderstorm = val),
          ),
          Divider(color: AppColors.grey516173Color.withOpacity(0.2), height: 16.h),
          _buildToggleItem(
            icon: Icons.umbrella_rounded,
            iconColor: Colors.lightBlue,
            label: 'Rain Alert',
            value: _alertOnRain,
            onChanged: (val) => setState(() => _alertOnRain = val),
          ),
          Divider(color: AppColors.grey516173Color.withOpacity(0.2), height: 16.h),
          _buildToggleItem(
            icon: Icons.wb_sunny_rounded,
            iconColor: Colors.orange,
            label: 'Sunny Day / Good Alert',
            value: _alertOnGoodSunny,
            onChanged: (val) => setState(() => _alertOnGoodSunny = val),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: getTextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
            activeTrackColor: iconColor.withOpacity(0.3),
            inactiveThumbColor: AppColors.grey516173Color,
            inactiveTrackColor: AppColors.grey516173Color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel — flex 1
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.grey516173Color.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Cancel',
                style: getTextStyle(
                  fontSize: 14,
                  color: AppColors.grey8B95A5Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Save — flex 2, height-constrained so content never overflows
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealColor117A88,
                disabledBackgroundColor:
                    AppColors.tealColor117A88.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
                // Prevent button from adding extra internal padding that
                // could fight with the SizedBox height.
                padding: EdgeInsets.zero,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            widget.isEditing ? 'Update Alert' : 'Watch Zone',
                            style: getTextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    await EasyLoading.show(
      status: widget.isEditing ? 'Updating settings...' : 'Watching zone...',
    );
    setState(() => _isSaving = true);
    try {
      final updated = widget.config.copyWith(
        alertsEnabled: _alertsEnabled,
        waveHeightThresholdFt: _waveThreshold,
        windSpeedThresholdMph: _windThreshold,
        waterTempChangeDeltaF: _tempDelta,
        alertOnThunderstorm: _alertOnThunderstorm,
        alertOnRain: _alertOnRain,
        alertOnGoodSunny: _alertOnGoodSunny,
      );

      final controller = Get.find<WeatherAlertController>();
      if (widget.isEditing) {
        await controller.updateZone(updated);
      } else {
        await controller.addZone(updated);
      }

      await EasyLoading.showSuccess(
        widget.isEditing
            ? '${updated.zoneName} alert thresholds saved.'
            : 'You\'ll be notified when conditions change in ${updated.zoneName}.',
      );
      Get.back();
    } catch (e) {
      await EasyLoading.dismiss();
      await EasyLoading.showError('An error occurred.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

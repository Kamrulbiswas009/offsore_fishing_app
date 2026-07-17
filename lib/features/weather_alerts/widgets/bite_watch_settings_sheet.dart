import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';
import 'package:paytonpieper/features/weather_alerts/model/bite_watch_model.dart';

class BiteWatchSettingsSheet extends StatefulWidget {
  final String zoneId;
  final BiteWatchModel? config;
  final bool isEditing;

  const BiteWatchSettingsSheet({
    super.key,
    required this.zoneId,
    this.config,
    this.isEditing = false,
  });

  static Future<void> show({
    required String zoneId,
    BiteWatchModel? config,
    bool isEditing = false,
  }) {
    return Get.bottomSheet(
      BiteWatchSettingsSheet(zoneId: zoneId, config: config, isEditing: isEditing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  State<BiteWatchSettingsSheet> createState() => _BiteWatchSettingsSheetState();
}

class _BiteWatchSettingsSheetState extends State<BiteWatchSettingsSheet>
    with SingleTickerProviderStateMixin {
  late bool _watchBiteActivity;
  late int _biteThreshold;
  late int _biteThresholdDays;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _watchBiteActivity = widget.config?.watchBiteActivity ?? true;
    _biteThreshold = widget.config?.biteThreshold ?? 3;
    _biteThresholdDays = widget.config?.biteThresholdDays ?? 7;

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
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
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
              // Header section
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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

              // Sliders section
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 8.h),
                  child: AnimatedOpacity(
                    opacity: _watchBiteActivity ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !_watchBiteActivity,
                      child: Column(
                        children: [
                          _buildStepperSection(
                            icon: Icons.phishing,
                            iconColor: const Color(0xFFFF6D00),
                            label: 'Report Count Threshold',
                            description: 'Notify me on at least',
                            value: _biteThreshold,
                            min: 1,
                            max: 50,
                            unit: 'reports',
                            onChanged: (v) => setState(() => _biteThreshold = v),
                          ),
                          SizedBox(height: 18.h),
                          _buildStepperSection(
                            icon: Icons.calendar_month_outlined,
                            iconColor: const Color(0xFF00D4FF),
                            label: 'Time Frame Window',
                            description: 'Within a window of',
                            value: _biteThresholdDays,
                            min: 1,
                            max: 30,
                            unit: 'days',
                            onChanged: (v) => setState(() => _biteThresholdDays = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Save / Cancel row
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
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6D00).withOpacity(0.3),
                const Color(0xFFFF6D00).withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFFF6D00).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.notifications_active_rounded,
            color: const Color(0xFFFF6D00),
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Bite Watch Settings' : 'Watch Bite Activity',
                style: getTextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Zone ID: ${widget.zoneId}',
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.grey8B95A5Color,
                  fontWeight: FontWeight.w400,
                ),
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
          color: _watchBiteActivity
              ? const Color(0xFFFF6D00).withOpacity(0.5)
              : AppColors.grey516173Color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _watchBiteActivity
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: _watchBiteActivity
                ? const Color(0xFFFF6D00)
                : AppColors.grey516173Color,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bite Alerts',
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _watchBiteActivity
                      ? 'Notify me when recent reports spike'
                      : 'Bite alerts paused for this zone',
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
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _watchBiteActivity,
              onChanged: (v) => setState(() => _watchBiteActivity = v),
              activeColor: const Color(0xFFFF6D00),
              activeTrackColor: const Color(0xFFFF6D00).withOpacity(0.4),
              inactiveThumbColor: AppColors.grey516173Color,
              inactiveTrackColor: AppColors.grey516173Color.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String description,
    required int value,
    required int min,
    required int max,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: iconColor, size: 15.sp),
              ),
              SizedBox(width: 10.w),
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
                    ),
                    Text(
                      description,
                      style: getTextStyle(
                        fontSize: 11,
                        color: AppColors.grey8B95A5Color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Text(
                  '$value $unit',
                  style: getTextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: iconColor, size: 22.sp),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: iconColor,
                    inactiveTrackColor: iconColor.withOpacity(0.15),
                    thumbColor: iconColor,
                    overlayColor: iconColor.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: max - min,
                    onChanged: (val) => onChanged(val.toInt()),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: iconColor, size: 22.sp),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.grey516173Color.withOpacity(0.4)),
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
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
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
                  : Text(
                      widget.isEditing ? 'Update Settings' : 'Watch Zone',
                      style: getTextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    await EasyLoading.show(
      status: widget.isEditing ? 'Updating settings...' : 'Watching zone...',
    );
    setState(() => _isSaving = true);
    try {
      final controller = Get.find<BiteWatchController>();
      bool success = false;
      if (widget.isEditing) {
        success = await controller.updateWatchSettings(
          widget.zoneId,
          watchBiteActivity: _watchBiteActivity,
          biteThreshold: _biteThreshold,
          biteThresholdDays: _biteThresholdDays,
        );
      } else {
        success = await controller.watchZone(
          widget.zoneId,
          threshold: _biteThreshold,
          days: _biteThresholdDays,
        );
      }

      if (success) {
        await EasyLoading.showSuccess(
          widget.isEditing
              ? 'Bite threshold settings saved successfully.'
              : 'You will receive alerts for bite activity spikes in ${widget.zoneId}.',
        );
        Get.back();
      } else {
        await EasyLoading.dismiss();
        await EasyLoading.showError(
          'Could not update watch settings. Please check network connection.',
        );
      }
    } catch (e) {
      await EasyLoading.dismiss();
      await EasyLoading.showError('An error occurred.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

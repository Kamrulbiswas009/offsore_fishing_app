import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/settings_screen_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_action_tile_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_info_tile_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_section_header_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_switch_tile_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/storage_progress_bar_widget.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsScreenController controller =
      Get.find<SettingsScreenController>();
  final ProfileMainScreenController profileMainScreenController = Get.find<ProfileMainScreenController>();
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CustomBackButton(ontap: Get.back),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 44.w),
                ],
              ),
              SizedBox(height: 18.h),
              const SettingsSectionHeaderWidget(
                title: 'Offline Storage',
                iconPath: IconPath.offlineStorageIcon,
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.containerBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.tealColor117A88),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => SettingsSwitchTileWidget(
                        title: 'Enable Offline Mode',
                        subtitle: 'Download data for offline access',
                        value: controller.isOfflineModeEnabled.value,
                        onChanged: controller.toggleOfflineMode,
                      ),
                    ),
                    Divider(
                      color: AppColors.grey516173Color.withValues(alpha: 0.45),
                      height: 26.h,
                    ),
                    Obx(() {
                      final isDownloading = controller.isDownloadingMap;
                      final progress = controller.downloadProgress;
                      final status = controller.downloadStatusMessage;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SettingsActionTileWidget(
                            title: isDownloading
                                ? 'Downloading Map... (${progress.toStringAsFixed(0)}%)'
                                : 'Download Map Area',
                            leadingIcon: IconPath.downloadIcon,
                            onTap: isDownloading
                                ? () {}
                                : controller.downloadMapArea,
                          ),
                          if (isDownloading) ...[
                            SizedBox(height: 6.h),
                            Text(
                              status,
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontSize: 13,
                                color: AppColors.blue00F0FFColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Text(
                                'Storage Used',
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.whiteE5E7EBColor,
                                  lineHeight: 10,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${controller.storageUsedInMb} MB / ${controller.totalStorageInMb} MB',
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey8B95A5Color,
                                  lineHeight: 10,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          StorageProgressBarWidget(
                            progress: controller.storageProgress,
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        fontSize: 14,
                        lineHeight: 10,
                        borderColor: Color(0xFF522F26),
                        ontap: controller.clearOfflineData,
                        title: 'Clear Offline Data',
                        bgColor: Color(0xFFFB2C36).withValues(alpha: 0.10),
                        titleColor: Color(0xFFFF6467),
                        borderRadius: 12.r,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.asset(
                            IconPath.deleteIcon,
                            width: 16.r,
                            height: 16.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              const SettingsSectionHeaderWidget(
                title: 'Account',
                iconPath: IconPath.deleteIcon,
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.containerBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.redDA605CColor.withValues(alpha: 0.65),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Delete Account',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Permanently delete your account and associated data.',
                      style: getTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey8B95A5Color,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    CustomButton(
                      fontSize: 14,
                      lineHeight: 10,
                      borderColor: AppColors.redDA605CColor,
                      ontap: controller.confirmAndDeleteAccount,
                      title: 'Delete Account',
                      bgColor: AppColors.redDA605CColor.withValues(alpha: 0.10),
                      titleColor: AppColors.redDA605CColor,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Image.asset(
                          IconPath.deleteIcon,
                          width: 16.r,
                          height: 16.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              const SettingsSectionHeaderWidget(
                title: 'Notifications',
                iconPath: IconPath.notificationTealIcon,
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: profileMainScreenController.isPremiumAccount? AppColors.containerBackgroundColor : AppColors.grey516173Color,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.tealColor117A88),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => SettingsSwitchTileWidget(
                        title: 'Enable Notifications',
                        subtitle: 'Get bite, weather, and group alerts',
                        value: controller.isNotificationsEnabled.value,
                        onChanged: profileMainScreenController.isPremiumAccount? controller.toggleNotifications:(value) {
                          EasyLoading.showInfo("Upgrade pro plan to active");
                        },
                      ),
                    ),
                    Divider(color: Color(0xFF055467), height: 26.h),
                    Obx(
                      () => SettingsSwitchTileWidget(
                        title: 'Hot Zone Alerts',
                        subtitle: 'Alerts when the bite is on',
                        value: controller.isHotZoneAlertsEnabled.value,
                        onChanged: profileMainScreenController.isPremiumAccount? controller.toggleHotZoneAlerts:(value) {
                          EasyLoading.showInfo("Upgrade pro plan to active");
                        },
                      ),
                    ),
                    Divider(color: Color(0xFF055467), height: 26.h),
                    //SizedBox(height: 14.h),
                    Obx(
                      () => SettingsSwitchTileWidget(
                        title: 'Group Activity',
                        subtitle: 'New reports and members',
                        value: controller.isGroupActivityEnabled.value,
                        onChanged: profileMainScreenController.isPremiumAccount? controller.toggleGroupActivity:(value) {
                          EasyLoading.showInfo("Upgrade pro plan to active");
                        },
                      ),
                    ),
                    Divider(color: const Color(0xFF055467), height: 26.h),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Quiet Hours',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteColor,
                          lineHeight: 12,
                        ),
                      ),
                      subtitle: Text(
                        'Mute Group Intel alerts temporarily or daily',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey8B95A5Color,
                          lineHeight: 10,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey8B95A5Color,
                        size: 22.r,
                      ),
                      onTap: profileMainScreenController.isPremiumAccount
                          ? () => _showQuietHoursBottomSheet(context)
                          : () => EasyLoading.showInfo("Upgrade pro plan to active"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              const SettingsSectionHeaderWidget(
                title: 'About',
                iconPath: IconPath.aboutIcon,
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.containerBackgroundColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.tealColor117A88),
                ),
                child: Column(
                  children: [
                    for (
                      int index = 0;
                      index < controller.aboutItems.length;
                      index++
                    )
                      SettingsInfoTileWidget(
                        title: controller.aboutItems[index].title,
                        trailingText: controller.aboutItems[index].trailingText,
                        showDivider: index != controller.aboutItems.length - 1,
                        onTap: () => controller.handleAboutItemTap(
                          controller.aboutItems[index],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuietHoursBottomSheet(BuildContext context) {
    TimeOfDay selectedStartTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay selectedEndTime = const TimeOfDay(hour: 7, minute: 0);
    final currentStatus = controller.quietHoursStatus.value;
    if (currentStatus != null && currentStatus.startsWith('Daily')) {
      try {
        final cleaned = currentStatus.replaceAll('Daily', '').trim();
        final times = cleaned.split('-');
        if (times.length == 2) {
          final startStr = times[0].trim();
          final endStr = times[1].trim();
          
          final startDf = DateFormat('h:mm a').parse(startStr);
          final endDf = DateFormat('h:mm a').parse(endStr);
          
          selectedStartTime = TimeOfDay(hour: startDf.hour, minute: startDf.minute);
          selectedEndTime = TimeOfDay(hour: endDf.hour, minute: endDf.minute);
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDarkColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: AppColors.tealColor117A88, width: 1.w),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 16.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Quiet Hours for Group Intel",
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Obx(() {
                      final status = controller.quietHoursStatus.value;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: status != null 
                              ? AppColors.orangeFF6B35Color.withOpacity(0.15) 
                              : AppColors.tealColor117A88.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: status != null ? AppColors.orangeFF6B35Color : AppColors.tealColor117A88,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              status != null ? Icons.do_not_disturb_on : Icons.check_circle,
                              color: status != null ? AppColors.orangeFF6B35Color : AppColors.tealColor117A88,
                              size: 16.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                status != null ? "Current Status: $status" : "Current Status: Alerts Active",
                                style: getTextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),
                    Text(
                      "Mute Temporarily",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey8B95A5Color,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDurationButton(context, 1, "1 Hr"),
                        _buildDurationButton(context, 3, "3 Hrs"),
                        _buildDurationButton(context, 8, "8 Hrs"),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Daily Recurring Quiet Hours",
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey8B95A5Color,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePickerTile(
                            context,
                            title: "Starts At",
                            time: selectedStartTime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedStartTime,
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedStartTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTimePickerTile(
                            context,
                            title: "Ends At",
                            time: selectedEndTime,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedEndTime,
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedEndTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    CustomButton(
                      title: "Apply Daily Schedule",
                      fontSize: 14,
                      lineHeight: 10,
                      bgColor: AppColors.tealColor117A88,
                      titleColor: AppColors.whiteColor,
                      borderRadius: 12.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      ontap: () {
                        final startStr = "${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}";
                        final endStr = "${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}";
                        Get.back();
                        controller.setQuietHours(localStart: startStr, localEnd: endStr);
                      },
                    ),
                    Obx(() {
                      if (controller.quietHoursStatus.value == null) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: CustomButton(
                          title: "Clear Quiet Hours / Resume Alerts",
                          fontSize: 14,
                          lineHeight: 10,
                          borderColor: AppColors.redDA605CColor,
                          bgColor: AppColors.redDA605CColor.withValues(alpha: 0.10),
                          titleColor: AppColors.redDA605CColor,
                          borderRadius: 12.r,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          ontap: () {
                            Get.back();
                            controller.setQuietHours(clear: true);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDurationButton(BuildContext context, int hours, String label) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.tealColor117A88),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            padding: EdgeInsets.symmetric(vertical: 10.h),
          ),
          onPressed: () {
            Get.back();
            controller.setQuietHours(durationHours: hours);
          },
          child: Text(
            label,
            style: getTextStyle(color: AppColors.whiteColor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(BuildContext context, {required String title, required TimeOfDay time, required VoidCallback onTap}) {
    final timeStr = time.format(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.containerBackgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.tealColor117A88.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: getTextStyle(fontSize: 12, color: AppColors.grey8B95A5Color),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeStr,
                  style: getTextStyle(fontSize: 16, color: AppColors.whiteColor, fontWeight: FontWeight.w500),
                ),
                Icon(Icons.access_time, color: AppColors.tealColor117A88, size: 18.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

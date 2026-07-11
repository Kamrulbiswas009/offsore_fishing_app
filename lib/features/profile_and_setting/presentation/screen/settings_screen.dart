import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/settings_screen_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_action_tile_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_info_tile_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_section_header_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/settings_switch_tile_widget.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/settings_screen_widget/storage_progress_bar_widget.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsScreenController controller =
      Get.find<SettingsScreenController>();

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
                            onTap: isDownloading ? () {} : controller.downloadMapArea,
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
                          child: Image.asset(IconPath.deleteIcon,
                              width: 16.r, height: 16.r),
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
                  color: AppColors.containerBackgroundColor,
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
                        onChanged: controller.toggleNotifications,
                      ),
                    ),
                    Divider(
                      color: Color(0xFF055467),
                      height: 26.h,
                    ),
                    Obx(
                      () => SettingsSwitchTileWidget(
                        title: 'Hot Zone Alerts',
                        subtitle: 'Alerts when the bite is on',
                        value: controller.isHotZoneAlertsEnabled.value,
                        onChanged: controller.toggleHotZoneAlerts,
                      ),
                    ),
                    Divider(
                      color: Color(0xFF055467),
                      height: 26.h,
                    ),
                    //SizedBox(height: 14.h),
                    Obx(
                      () => SettingsSwitchTileWidget(
                        title: 'Group Activity',
                        subtitle: 'New reports and members',
                        value: controller.isGroupActivityEnabled.value,
                        onChanged: controller.toggleGroupActivity,
                      ),
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
              SizedBox(height: 25.h,),
            ],
          ),
        ),
      ),
    );
  }
}

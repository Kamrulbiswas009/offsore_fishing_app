import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/mapbox_offline_service.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/offline_cache_service.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class SettingsScreenController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  final RxBool isOfflineModeEnabled = true.obs;
  final RxBool isNotificationsEnabled = false.obs;
  final RxBool isHotZoneAlertsEnabled = false.obs;
  final RxBool isGroupActivityEnabled = false.obs;

  int get storageUsedInMb => MapboxOfflineService.to.storageUsedInMb.value;
  int get totalStorageInMb => 500;

  bool get isDownloadingMap => MapboxOfflineService.to.isDownloading.value;
  double get downloadProgress => MapboxOfflineService.to.downloadProgress.value;
  String get downloadStatusMessage =>
      MapboxOfflineService.to.statusMessage.value;

  late final List<SettingsAboutItemModel> aboutItems =
      const <SettingsAboutItemModel>[
        SettingsAboutItemModel(title: 'Version', trailingText: '1.0.0'),
        SettingsAboutItemModel(title: 'Privacy Policy'),
        SettingsAboutItemModel(title: 'Terms of Service'),
        SettingsAboutItemModel(title: 'Help & Support'),
      ];

  double get storageProgress => storageUsedInMb / totalStorageInMb;

  final RxnString quietHoursStatus = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchGeneralSettings();
    fetchNotificationPreferences();
  }

  Future<void> fetchGeneralSettings() async {
    try {
      final token = StorageService.token;
      if (token == null || token.isEmpty) return;
      final response = await _networkCaller.getRequest(
        ApiConstants.generalNotificationSettingsApi,
        token: 'Bearer $token',
      );
      if (response.isSuccess) {
        final data = response.responseData['data'];
        if (data != null) {
          isNotificationsEnabled.value = data['enableNotification'] ?? false;
          isGroupActivityEnabled.value = data['groupActivity'] ?? false;
          isHotZoneAlertsEnabled.value = data['hotZoneAlert'] ?? false;
          isOfflineModeEnabled.value = data['enableOfflineMap'] ?? false;
        }
      }
    } catch (e) {
      AppLoggerHelper.error('Failed to fetch general settings', e);
    }
  }

  Future<void> updateGeneralSettings({
    bool? enableNotification,
    bool? groupActivity,
    bool? hotZoneAlert,
    bool? enableOfflineMap,
  }) async {
    try {
      final token = StorageService.token;
      if (token == null || token.isEmpty) return;
      final body = <String, dynamic>{
        if (enableNotification != null) 'enableNotification': enableNotification,
        if (groupActivity != null) 'groupActivity': groupActivity,
        if (hotZoneAlert != null) 'hotZoneAlert': hotZoneAlert,
        if (enableOfflineMap != null) 'enableOfflineMap': enableOfflineMap,
      };
      final response = await _networkCaller.patchRequest(
        ApiConstants.generalNotificationSettingsApi,
        body: body,
        token: 'Bearer $token',
      );
      if (!response.isSuccess) {
        EasyLoading.showError('Failed to update settings');
      }
    } catch (e) {
      AppLoggerHelper.error('Failed to update general settings', e);
    }
  }

  void toggleOfflineMode(bool value) {
    isOfflineModeEnabled.value = value;
    updateGeneralSettings(enableOfflineMap: value);
  }

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
    updateGeneralSettings(enableNotification: value);
  }

  void toggleHotZoneAlerts(bool value) {
    isHotZoneAlertsEnabled.value = value;
    updateGeneralSettings(hotZoneAlert: value);
  }

  void toggleGroupActivity(bool value) {
    isGroupActivityEnabled.value = value;
    updateGeneralSettings(groupActivity: value);
  }

  Future<void> fetchNotificationPreferences() async {
    try {
      final token = StorageService.token;
      if (token == null || token.isEmpty) return;
      final response = await _networkCaller.getRequest(
        ApiConstants.preferenceNotificationSettingsApi,
        token: 'Bearer $token',
      );
      if (response.isSuccess) {
        final body = response.responseData;
        final data = body['data'];
        if (data is List) {
          final groupIntelPref = data.firstWhere((p) => p['type'] == 'GROUP_INTEL', orElse: () => null);
          if (groupIntelPref != null) {
            _updateQuietHoursUI(groupIntelPref);
          }
        } else if (data is Map) {
          if (data['type'] == 'GROUP_INTEL') {
            _updateQuietHoursUI(data);
          }
        }
      }
    } catch (e) {
      AppLoggerHelper.error('Failed to fetch preferences', e);
    }
  }

  void _updateQuietHoursUI(Map<dynamic, dynamic> pref) {
    final start = pref['quietStart'];
    final end = pref['quietEnd'];
    if (start != null && end != null) {
      quietHoursStatus.value = 'Daily ${convertUtcToLocalTime(start.toString())} - ${convertUtcToLocalTime(end.toString())}';
    } else if (pref['quietEnd'] != null) {
      final endUtc = DateTime.tryParse(pref['quietEnd'].toString());
      if (endUtc != null) {
        final localEnd = endUtc.toLocal();
        if (localEnd.isAfter(DateTime.now())) {
          final formatted = DateFormat('h:mm a').format(localEnd);
          quietHoursStatus.value = 'Muted until $formatted';
          return;
        }
      }
      quietHoursStatus.value = null;
    } else {
      quietHoursStatus.value = null;
    }
  }

  String convertLocalTimeToUtc(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final now = DateTime.now();
      final localTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      final utcTime = localTime.toUtc();
      return DateFormat('HH:mm').format(utcTime);
    } catch (_) {
      return hhmm;
    }
  }

  String convertUtcToLocalTime(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final now = DateTime.now().toUtc();
      final utcTime = DateTime.utc(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      final localTime = utcTime.toLocal();
      return DateFormat('h:mm a').format(localTime);
    } catch (_) {
      return hhmm;
    }
  }

  Future<void> setQuietHours({
    int? durationHours,
    String? localStart,
    String? localEnd,
    bool clear = false,
  }) async {
    final token = StorageService.token;
    if (token == null || token.isEmpty) return;

    final body = <String, dynamic>{
      'type': 'GROUP_INTEL',
    };
    if (clear) {
      body['clearQuietHours'] = true;
    } else if (durationHours != null) {
      body['quietDurationHours'] = durationHours;
    } else if (localStart != null && localEnd != null) {
      body['quietStart'] = convertLocalTimeToUtc(localStart);
      body['quietEnd'] = convertLocalTimeToUtc(localEnd);
    }

    await EasyLoading.show(status: 'Updating quiet hours...');
    try {
      final response = await _networkCaller.putRequest(
        ApiConstants.preferenceNotificationSettingsApi,
        body: body,
        token: 'Bearer $token',
      );

      if (response.isSuccess) {
        EasyLoading.showSuccess('Quiet hours updated successfully');
        final data = response.responseData['data'];
        if (data is Map) {
          _updateQuietHoursUI(data);
        }
      } else {
        EasyLoading.showError(response.errorMessage.isNotEmpty ? response.errorMessage : 'Failed to update quiet hours');
      }
    } catch (e) {
      AppLoggerHelper.error('Exception setting quiet hours', e);
      EasyLoading.showError('Something went wrong');
    } finally {
      await EasyLoading.dismiss();
    }
  }

  void downloadMapArea() {
    MapboxOfflineService.to.startOfflineDownload();
  }

  void clearOfflineData() {
    MapboxOfflineService.to.clearOfflineMap();
  }

  void handleAboutItemTap(SettingsAboutItemModel item) {}

  Future<void> confirmAndDeleteAccount() async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.containerBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.redDA605CColor),
        ),
        title: Text(
          'Delete Account?',
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
          ),
        ),
        content: Text(
          'This action is permanent. Your account and all associated data will be deleted.',
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.greyC8D0DBColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: getTextStyle(color: AppColors.greyC8D0DBColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: getTextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.redDA605CColor,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (shouldDelete != true) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    await EasyLoading.show(status: 'Deleting account...');

    try {
      final accessToken = StorageService.token;
      if (accessToken == null || accessToken.isEmpty) {
        CommonMessage.showMessage(
          title: 'Delete failed',
          message: 'Your session has expired. Please log in again.',
        );
        return;
      }

      final response = await _networkCaller.deleteRequest(
        ApiConstants.deleteAccountApi,
        token: 'Bearer $accessToken',
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Account deletion failed (${response.statusCode}): ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Delete failed',
          message: response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Could not delete your account. Please try again.',
        );
        return;
      }

      try {
        await Get.find<OfflineCacheService>().clearAll();
      } catch (error) {
        AppLoggerHelper.error(
          'Failed to clear offline cache after account deletion.',
          error,
        );
      }
      await StorageService.logoutUser();
      AppLoggerHelper.info('Account deleted and local data cleared.');

      Get.offAllNamed(AppRoute.getLoginScreen());
    } catch (error) {
      AppLoggerHelper.error('Account deletion failed unexpectedly.', error);
      CommonMessage.showMessage(
        title: 'Delete failed',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }
}

class SettingsAboutItemModel {
  final String title;
  final String? trailingText;

  const SettingsAboutItemModel({required this.title, this.trailingText});
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
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
  final RxBool isNotificationsEnabled = true.obs;
  final RxBool isHotZoneAlertsEnabled = true.obs;
  final RxBool isGroupActivityEnabled = true.obs;

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

  void toggleOfflineMode(bool value) {
    isOfflineModeEnabled.value = value;
  }

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
  }

  void toggleHotZoneAlerts(bool value) {
    isHotZoneAlertsEnabled.value = value;
  }

  void toggleGroupActivity(bool value) {
    isGroupActivityEnabled.value = value;
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

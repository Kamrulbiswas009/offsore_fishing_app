import 'package:get/get.dart';
import 'package:paytonpieper/core/services/mapbox_offline_service.dart';

class SettingsScreenController extends GetxController {
  final RxBool isOfflineModeEnabled = true.obs;
  final RxBool isNotificationsEnabled = true.obs;
  final RxBool isHotZoneAlertsEnabled = true.obs;
  final RxBool isGroupActivityEnabled = true.obs;

  int get storageUsedInMb => MapboxOfflineService.to.storageUsedInMb.value;
  int get totalStorageInMb => 500;

  bool get isDownloadingMap => MapboxOfflineService.to.isDownloading.value;
  double get downloadProgress => MapboxOfflineService.to.downloadProgress.value;
  String get downloadStatusMessage => MapboxOfflineService.to.statusMessage.value;

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
}

class SettingsAboutItemModel {
  final String title;
  final String? trailingText;

  const SettingsAboutItemModel({required this.title, this.trailingText});
}

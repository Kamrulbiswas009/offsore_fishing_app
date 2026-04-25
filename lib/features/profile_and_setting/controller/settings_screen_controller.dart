import 'package:get/get.dart';

class SettingsScreenController extends GetxController {
  final RxBool isOfflineModeEnabled = true.obs;
  final RxBool isNotificationsEnabled = true.obs;
  final RxBool isHotZoneAlertsEnabled = true.obs;
  final RxBool isGroupActivityEnabled = true.obs;

  final int storageUsedInMb = 245;
  final int totalStorageInMb = 500;

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

  void downloadMapArea() {}

  void clearOfflineData() {}

  void handleAboutItemTap(SettingsAboutItemModel item) {}
}

class SettingsAboutItemModel {
  final String title;
  final String? trailingText;

  const SettingsAboutItemModel({required this.title, this.trailingText});
}

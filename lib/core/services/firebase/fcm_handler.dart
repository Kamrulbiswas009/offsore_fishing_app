import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/routes/app_routes.dart';

import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';

/// Handles FCM foreground and tap-open events.
/// Background messages are handled by [_firebaseMessagingBackgroundHandler]
/// which is registered in [AppNotificationInitializer].
class FCMHandler {
  static void configure() {
    // Foreground messages — show as GetX snackbar if not already handled
    // by WeatherAlertService directly.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLoggerHelper.info('[FCM] Foreground message: ${message.notification?.title}');
      _routeMessage(message);
    });

    // User tapped a notification while app was in background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLoggerHelper.info('[FCM] Notification tap (background): ${message.data}');
      _handleTap(message.data);
    });
  }

  static void _routeMessage(RemoteMessage message) {
    final type = message.data['type'] as String?;
    if (type == 'weather_alert') {
      // Weather alert already handled by WeatherAlertService snackbar in-process;
      // only show if it was a push from a different source.
      final zoneName = message.data['zoneName'] as String? ?? 'Zone';
      final body = message.notification?.body ?? 'Conditions changed';
      Get.snackbar(
        '🌊 $zoneName',
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
      );
    }
  }

  static void _handleTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == 'weather_alert') {
      // Navigate to weather tab on the summary screen
      final zoneId = data['zoneId'] as String? ?? 'GOM-R74-C88';
      final zoneName = data['zoneName'] as String? ?? zoneId;
      final lat = double.tryParse(data['lat']?.toString() ?? '') ?? 28.375;
      final lng = double.tryParse(data['lng']?.toString() ?? '') ?? -89.125;

      final liveZone = MapZoneModel(
        id: zoneId,
        name: zoneName,
        location: LatLng(lat, lng),
        count: 0,
        level: ActivityLevel.medium,
      );
      Get.toNamed(AppRoute.summaryScreen, arguments: liveZone);
    }
  }

  /// Must be a top-level function for background FCM handling.
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    AppLoggerHelper.info('[FCM] Background message: ${message.notification?.title}');
  }
}
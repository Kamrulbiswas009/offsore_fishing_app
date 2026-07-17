import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/routes/app_routes.dart';

import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/main_screen/controller/main_screen_controller.dart';

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
    } else if (type == 'BITE_ACTIVITY') {
      final zoneId = message.data['zoneId'] as String? ?? 'Zone';
      final title = message.notification?.title ?? 'Bite Activity Alert';
      final body = message.notification?.body ?? 'Activity spike detected.';
      Get.snackbar(
        '🎣 $title',
        body,
        backgroundColor: const Color(0xFFFF6D00).withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
        onTap: (_) => _handleTap(message.data),
      );
    } else if (type == 'GROUP_INTEL') {
      final title = message.notification?.title ?? 'New Group Intel';
      final body = message.notification?.body ?? 'A new report was shared in your group.';
      Get.snackbar(
        '👥 $title',
        body,
        backgroundColor: const Color(0xFF117A88).withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
        onTap: (_) => _handleTap(message.data),
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
    } else if (type == 'BITE_ACTIVITY') {
      final zoneId = data['zoneId'] as String? ?? 
          (data['deepLink'] as String?)?.split('/').last ?? 'GOM-0042';
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
    } else if (type == 'GROUP_INTEL') {
      final groupId = data['groupId'] as String? ?? '';
      final reportId = data['reportId'] as String? ?? '';

      if (reportId.isNotEmpty) {
        Get.toNamed(
          AppRoute.reportDetailsScreen,
          arguments: {
            'reportId': reportId,
          },
        );
      } else if (groupId.isNotEmpty) {
        try {
          Get.find<MainScreenController>().changeIndex(2);
        } catch (_) {}
        Get.toNamed(
          AppRoute.getGroupDetailsScreen(),
          arguments: {
            'groupId': groupId,
            'initialTab': 'reports',
          },
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute == AppRoute.getGroupDetailsScreen()) {
            Get.find<GroupDetailsScreenController>().fetchGroupDetails(groupId);
          }
        });
      }
    }
  }

  /// Must be a top-level function for background FCM handling.
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    AppLoggerHelper.info('[FCM] Background message: ${message.notification?.title}');
  }
}
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/core/services/firebase/notification_service.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/main_screen/controller/main_screen_controller.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/routes/app_routes.dart';

/// Handles FCM push notifications across all modes:
/// 1. Foreground Mode (App Open) -> shows local notification + in-app snackbar
/// 2. Background / Minimize Mode -> handles notification tap
/// 3. Terminated / Closed Mode -> handles initial message on launch
class FCMHandler {
  static void configure() {
    // 1. Foreground Messages (In-App Mode)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLoggerHelper.info(
          '[FCM] Foreground message: ${message.notification?.title}');

      // Trigger local notification to display system tray banner even in foreground
      final title = message.notification?.title ??
          message.data['title'] as String? ??
          'On The Bite';
      final body = message.notification?.body ??
          message.data['body'] as String? ??
          '';
      final imageUrl = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['imageUrl'] as String?;

      final payloadStr = jsonEncode(message.data);

      if (title.isNotEmpty || body.isNotEmpty) {
        NotificationService.sendLocalNotification(
          title: title,
          body: body,
          payload: payloadStr,
          imageUrl: imageUrl,
        );
      }

      _routeMessage(message);
    });

    // 2. Background / Minimize Mode: User tapped notification while app is minimized
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLoggerHelper.info(
          '[FCM] Notification tap (background/minimize): ${message.data}');
      handleTap(message.data);
    });
  }

  /// 3. Terminated / Closed Mode: Check if app was launched by tapping a notification
  static Future<void> checkInitialMessage() async {
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      AppLoggerHelper.info(
          '[FCM] Notification tap (terminated/closed): ${initialMessage.data}');
      handleTap(initialMessage.data);
    }
  }

  static void _routeMessage(RemoteMessage message) {
    final type = message.data['type'] as String?;
    if (type == 'weather_alert') {
      final zoneName = message.data['zoneName'] as String? ?? 'Zone';
      final body = message.notification?.body ?? 'Conditions changed';
      Get.snackbar(
        '🌊 $zoneName',
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
        onTap: (_) => handleTap(message.data),
      );
    } else if (type == 'BITE_ACTIVITY') {
      final title = message.notification?.title ?? 'Bite Activity Alert';
      final body = message.notification?.body ?? 'Activity spike detected.';
      Get.snackbar(
        '🎣 $title',
        body,
        backgroundColor: const Color(0xFFFF6D00).withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
        onTap: (_) => handleTap(message.data),
      );
    } else if (type == 'GROUP_INTEL') {
      final title = message.notification?.title ?? 'New Group Intel';
      final body =
          message.notification?.body ?? 'A new report was shared in your group.';
      Get.snackbar(
        '👥 $title',
        body,
        backgroundColor: const Color(0xFF117A88).withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 6),
        onTap: (_) => handleTap(message.data),
      );
    }
  }

  /// Routes screen navigation when a notification tap is received.
  static void handleTap(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    final type = data['type'] as String?;
    if (type == 'weather_alert' || type == 'BITE_ACTIVITY') {
      final zoneId = data['zoneId'] as String? ??
          (data['deepLink'] as String?)?.split('/').last ??
          'GOM-0042';
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
            Get.find<GroupDetailsScreenController>()
                .fetchGroupDetails(groupId);
          }
        });
      }
    } else if (data.containsKey('route')) {
      final route = data['route'] as String;
      Get.toNamed(route);
    }
  }

  /// Entry point for background message handling when app is in background or terminated.
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    AppLoggerHelper.info(
        '[FCM] Background message: ${message.notification?.title}');
  }
}
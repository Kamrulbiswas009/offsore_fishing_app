import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:paytonpieper/core/services/firebase/fcm_handler.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription =
      'This channel is used for important push notifications.';

  /// Initializing local notification system and notification channels.
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Create Android notification channel
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
        ),
      );
      await androidPlugin.requestNotificationsPermission();
    }

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          handleNotificationTap(payload);
        }
      },
    );

    AppLoggerHelper.info(
        '[NotificationService] Local notification system initialized.');
  }

  /// Display notification in notification panel/tray (with image caching if provided).
  static Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    int? notificationId,
  }) async {
    try {
      BigPictureStyleInformation? bigPictureStyle;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final imagePath = await _downloadAndSaveFile(
          imageUrl,
          'bigPicture_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        if (imagePath != null) {
          bigPictureStyle = BigPictureStyleInformation(
            FilePathAndroidBitmap(imagePath),
            contentTitle: title,
            summaryText: body,
          );
        }
      }

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: bigPictureStyle,
        playSound: true,
        icon: '@mipmap/launcher_icon',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final id =
          notificationId ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      AppLoggerHelper.error(
          '[NotificationService] Error showing notification: $e');
    }
  }

  /// Route user when notification is tapped from system tray
  static void handleNotificationTap(String payload) {
    try {
      Map<String, dynamic> data = {};
      if (payload.trim().startsWith('{')) {
        data = jsonDecode(payload) as Map<String, dynamic>;
      } else {
        data = {'type': payload};
      }
      FCMHandler.handleTap(data);
    } catch (e) {
      AppLoggerHelper.error(
          '[NotificationService] Handle notification tap error: $e');
    }
  }

  /// Helper function for downloading and saving notification image
  static Future<String?> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      AppLoggerHelper.error(
          '[NotificationService] Image download failed: $e');
    }
    return null;
  }

  // --------------------------------------- Notification Function For DEVELOPER ----------------------------------
  /// Function to send local notifications on demand
  static Future<void> sendLocalNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
    int? notificationId,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      payload: payload,
      imageUrl: imageUrl,
      notificationId: notificationId,
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/firebase/fcm_handler.dart';
import 'package:paytonpieper/core/services/firebase/notification_service.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';

/// Initializes Firebase Cloud Messaging and local notifications.
/// Call [AppNotificationInitializer.init()] in [main()] after Firebase.initializeApp().
class AppNotificationInitializer {
  /// Initialize local notifications, FCM permissions, and wire foreground/background handlers.
  static Future<void> init() async {
    // 1. Initialize local notifications plugin
    await NotificationService.init();

    final messaging = FirebaseMessaging.instance;

    // 2. Request notification permissions (iOS + Android 13+)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLoggerHelper.info(
        '[FCM] Permission status: ${settings.authorizationStatus}');

    // 3. Configure foreground presentation options for iOS
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Register the background message handler
    FirebaseMessaging.onBackgroundMessage(
      FCMHandler.firebaseMessagingBackgroundHandler,
    );

    // 5. Configure foreground and minimize mode tap handlers
    FCMHandler.configure();

    // 6. Check if app was launched from terminated state via notification tap
    await FCMHandler.checkInitialMessage();

    // 7. Log and persist device token for backend registration
    final token = await messaging.getToken();
    AppLoggerHelper.info('[FCM] Device token: $token');
    if (token != null && token.isNotEmpty) {
      await StorageService.saveFcmToken(token);
      try {
        final biteCtrl = Get.find<BiteWatchController>();
        await biteCtrl.uploadFcmToken();
      } catch (_) {
        // ControllerBinder runs after main(), so this is a best-effort.
      }
    }
  }
}
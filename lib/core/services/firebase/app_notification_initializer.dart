import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:paytonpieper/core/services/firebase/fcm_handler.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';

/// Initializes Firebase Cloud Messaging and registers the background handler.
/// Call [AppNotificationInitializer.init()] in [main()] after Firebase.initializeApp().
class AppNotificationInitializer {
  /// Initialize FCM, request permissions, and wire foreground/background handlers.
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request notification permissions (iOS + Android 13+)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLoggerHelper.info('[FCM] Permission status: ${settings.authorizationStatus}');

    // Register the background message handler (must be top-level function)
    FirebaseMessaging.onBackgroundMessage(
      FCMHandler.firebaseMessagingBackgroundHandler,
    );

    // Configure foreground + tap handlers
    FCMHandler.configure();

    // Log device token for backend registration
    final token = await messaging.getToken();
    AppLoggerHelper.info('[FCM] Device token: $token');
  }
}
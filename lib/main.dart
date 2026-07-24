import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/app.dart';
import 'package:paytonpieper/core/services/firebase/app_notification_initializer.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/services/weather_alert_service.dart';
import 'package:paytonpieper/core/utils/mapbox_config.dart';
import 'package:paytonpieper/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Critical, fast init that MUST complete before the first frame ---
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('[main] Firebase init error: $e');
  }

  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('[main] StorageService init error: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // edgeToEdge is cross-platform safe.
  // immersiveSticky is Android-only and breaks Flutter rendering on iOS,
  // causing a permanent white blank screen on physical iPhones.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  initializeMapbox();

  // --- Launch the widget tree FIRST, then do non-critical async work ---
  runApp(const Paytonpieper());

  // Defer FCM and weather monitoring to after the first frame so that
  // permission dialogs and network calls can never block the initial render.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // FCM push notification setup (may show a permission dialog on iOS)
    try {
      await AppNotificationInitializer.init();
    } catch (e) {
      debugPrint('[main] FCM init error: $e');
    }

    // Start background weather monitoring.
    // WeatherAlertService is registered in ControllerBinder, so we wait for
    // the first frame to ensure GetX DI is fully set up.
    try {
      Get.find<WeatherAlertService>().startMonitoring();
    } catch (_) {
      // Service not yet registered; ControllerBinder will handle it.
    }
  });
}

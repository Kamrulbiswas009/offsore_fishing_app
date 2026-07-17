import 'package:firebase_core/firebase_core.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await StorageService.init();

  // Initialize FCM push notifications
  await AppNotificationInitializer.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  initializeMapbox();
  runApp(const Paytonpieper());

  // Start background weather monitoring after the widget tree is ready.
  // WeatherAlertService is registered in ControllerBinder, so we wait for
  // the first frame to ensure GetX DI is fully set up.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      Get.find<WeatherAlertService>().startMonitoring();
    } catch (_) {
      // Service not yet registered; ControllerBinder will handle it.
    }
  });
}

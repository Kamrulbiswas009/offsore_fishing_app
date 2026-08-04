import 'package:firebase_core/firebase_core.dart';
import 'package:paytonpieper/core/services/firebase/app_notification_initializer.dart';
import 'package:paytonpieper/firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AppNotificationInitializer.init();
  }
}

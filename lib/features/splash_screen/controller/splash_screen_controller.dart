import 'dart:async';

import 'package:get/get.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class SplashScreenController extends GetxController {
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration _progressInterval = Duration(milliseconds: 10);

  final RxDouble loadingProgress = 0.0.obs;

  Timer? _progressTimer;
  bool _hasNavigated = false;

  @override
  void onReady() {
    super.onReady();
    startLoading();
  }

  void startLoading() {
    _progressTimer?.cancel();
    _hasNavigated = false;
    loadingProgress.value = 0;

    _progressTimer = Timer.periodic(_progressInterval, (timer) {
      final progress =
          (timer.tick * _progressInterval.inMilliseconds) /
          splashDuration.inMilliseconds;

      loadingProgress.value = progress.clamp(0.0, 1.0);

      if (loadingProgress.value >= 1 && !_hasNavigated) {
        _hasNavigated = true;
        _progressTimer?.cancel();
        Get.offAllNamed(AppRoute.getOnboardingScreen1());
      }
    });
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/permissions/location_permission_service.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  Future<void> login() async {
    final locationPermissionService = Get.find<LocationPermissionService>();
    final permissionResult =
        await locationPermissionService.requestLocationWhenInUse();

    if (permissionResult == LocationPermissionResult.permanentlyDenied) {
      Get.snackbar(
        'Location Permission',
        'Location access is blocked. You can enable it later from app settings.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (permissionResult == LocationPermissionResult.restricted) {
      Get.snackbar(
        'Location Permission',
        'Location access is restricted on this device.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (permissionResult == LocationPermissionResult.error) {
      Get.snackbar(
        'Location Permission',
        'Location permission could not be checked right now.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    Get.offAll(() => const MainScreen());
  }

  void forgotPassword() {
    Get.toNamed(AppRoute.getForgotPasswordScreen());
  }

  void continueWithGoogle() {}

  void continueWithApple() {}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

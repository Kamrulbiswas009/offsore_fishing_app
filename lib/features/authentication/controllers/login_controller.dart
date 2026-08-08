import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/permissions/location_permission_service.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';
import 'package:paytonpieper/features/authentication/controllers/apple_login_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/google_login_controller.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final NetworkCaller _networkCaller = NetworkCaller();

  final isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email address.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    await EasyLoading.show(status: 'Logging in...');
    try {
      // Fetch FCM token if available
      String? fcmToken;
      try {
        if (Platform.isIOS) {
          String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          int attempts = 0;
          while (apnsToken == null && attempts < 3) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            attempts++;
          }
          if (apnsToken != null) {
            fcmToken = await FirebaseMessaging.instance.getToken();
          }
        } else {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await StorageService.saveFcmToken(fcmToken);
        }
      } catch (_) {
        fcmToken = StorageService.fcmToken;
      }

      final response = await _networkCaller.postRequest(
        ApiConstants.loginApi,
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error('Login failed: ${response.errorMessage}');
        CommonMessage.showMessage(
          title: 'Login failed',
          message: response.errorMessage,
          backgroundColor: Colors.red,
        );
        return;
      }

      final responseBody = response.responseData;
      final data = responseBody is Map ? responseBody['data'] : null;
      final accessToken = data is Map ? data['accessToken'] : null;
      final refreshToken = data is Map ? data['refreshToken'] : null;

      if (accessToken is! String ||
          accessToken.isEmpty ||
          refreshToken is! String ||
          refreshToken.isEmpty) {
        AppLoggerHelper.error(
          'Login response did not contain valid auth tokens.',
        );
        CommonMessage.showMessage(
          title: 'Login failed',
          message: 'The server returned an invalid login response.',
          backgroundColor: Colors.red,
        );
        return;
      }

      await StorageService.saveAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      AppLoggerHelper.info('Login successful and auth tokens saved.');

      // Upload FCM token and refresh watched zones
      try {
        final biteCtrl = Get.find<BiteWatchController>();
        await biteCtrl.uploadFcmToken();
        await biteCtrl.fetchWatchedZones();
      } catch (e) {
        AppLoggerHelper.error('Failed to sync FCM / watched zones on login', e);
      }

      emailController.clear();
      passwordController.clear();
      AppLoggerHelper.info('Fcm Token : $fcmToken');
      
      
    } catch (error) {
      AppLoggerHelper.error('Login failed unexpectedly', error);
      CommonMessage.showMessage(
        title: 'Login failed',
        message: 'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
      );
      return;
    } finally {
      await EasyLoading.dismiss();
    }

    await _requestLocationPermission();
    Get.offAll(() =>  MainScreen());
  }

  Future<void> _requestLocationPermission() async {
    final permissionResult = await Get.find<LocationPermissionService>()
        .requestLocationWhenInUse();

    if (permissionResult == LocationPermissionResult.permanentlyDenied) {
      CommonMessage.showMessage(
        title: 'Location Permission',
        message: 'Location access is blocked. Enable it from app settings.',
      );
    } else if (permissionResult == LocationPermissionResult.restricted) {
      CommonMessage.showMessage(
        title: 'Location Permission',
        message: 'Location access is restricted on this device.',
      );
    } else if (permissionResult == LocationPermissionResult.error) {
      CommonMessage.showMessage(
        title: 'Location Permission',
        message: 'Location permission could not be checked right now.',
      );
    }
  }

  void forgotPassword() {
    Get.offNamed(AppRoute.getForgotPasswordScreen());
  }

  void continueWithGoogle() {
    Get.find<GoogleLoginController>().continueWithGoogle();
  }

  void continueWithApple() {
    Get.find<AppleLoginController>().continueWithApple();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

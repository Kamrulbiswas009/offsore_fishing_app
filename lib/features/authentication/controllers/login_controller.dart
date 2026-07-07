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
      final response = await _networkCaller.postRequest(
        ApiConstants.loginApi,
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
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
      emailController.clear();
      passwordController.clear();
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

  void continueWithGoogle() {}

  void continueWithApple() {}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

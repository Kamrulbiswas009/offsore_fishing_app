import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/set_new_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/verify_otp_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class ForgotPasswordScreenController extends GetxController {
  final emailController = TextEditingController();
  final otpFieldController = OtpFieldController();
  final TextEditingController newPasswordController = TextEditingController();

  final otpCode = ''.obs;
  final hasOtpError = false.obs;
  final isNewPasswordObscured = true.obs;
  final isLoading = false.obs;

  // Holds the email entered in ForgotPasswordScreen — shared across OTP & reset steps
  String _email = '';

  static const int otpLength = 6;

  final _networkCaller = NetworkCaller();

  void togglePasswordVisibility() {
    isNewPasswordObscured.value = !isNewPasswordObscured.value;
  }

  void backToLogin() {
    Get.offNamed(AppRoute.getLoginScreen());
  }

  void updateOtp(String value) {
    otpCode.value = value;
    if (value.length == otpLength) {
      hasOtpError.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Step 1 – Send OTP to email (ForgotPasswordScreen)
  // ─────────────────────────────────────────────
  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      CommonMessage.showMessage(
        title: 'Email Required',
        message: 'Please enter your email address.',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      CommonMessage.showMessage(
        title: 'Invalid Email',
        message: 'Please enter a valid email address.',
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _networkCaller.postRequest(
        ApiConstants.forgotEmailSendApi,
        body: {'email': email},
      );

      if (response.isSuccess) {
        _email = email;
        otpCode.value = '';
        hasOtpError.value = false;

        AppLoggerHelper.info(
          '[ForgotPassword] OTP sent successfully to $email | '
          'statusCode: ${response.statusCode}',
        );

        CommonMessage.showMessage(
          title: 'OTP Sent',
          message: response.responseData?['message'] ?? 'OTP sent to your email.',
        );

        Get.to(() => VerifyOtpScreen());
      } else {
        AppLoggerHelper.error(
          '[ForgotPassword] Failed to send OTP | '
          'statusCode: ${response.statusCode} | error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[ForgotPassword] sendOtp exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // Step 2 – Verify OTP (VerifyOtpScreen)
  // ─────────────────────────────────────────────
  void verifyOtp() {
    if (otpCode.value.length != otpLength) {
      hasOtpError.value = true;
      CommonMessage.showMessage(
        title: 'Invalid OTP',
        message: 'Please enter the $otpLength digit OTP sent to your email.',
      );
      return;
    }

    hasOtpError.value = false;

    AppLoggerHelper.info(
      '[ForgotPassword] OTP validated locally — navigating to SetNewPasswordScreen',
    );

    Get.to(() => SetNewPasswordScreen());
  }

  // ─────────────────────────────────────────────
  // Step 3 – Reset password (SetNewPasswordScreen)
  // Collects email (Step 1), otp (Step 2), newPassword (Step 3)
  // ─────────────────────────────────────────────
  Future<void> setNewPassword() async {
    final newPassword = newPasswordController.text.trim();

    if (newPassword.isEmpty) {
      CommonMessage.showMessage(
        title: 'Password Required',
        message: 'Please enter your new password.',
      );
      return;
    }

    if (newPassword.length < 8) {
      CommonMessage.showMessage(
        title: 'Password Too Short',
        message: 'Password must be at least 8 characters long.',
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _networkCaller.postRequest(
        ApiConstants.verifyForgotPasswordWithOtpApi,
        body: {
          'otp': otpCode.value,
          'email': _email,
          'newPassword': newPassword,
        },
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          '[ForgotPassword] Password reset successfully for $_email | '
          'statusCode: ${response.statusCode}',
        );

        CommonMessage.showMessage(
          title: 'Success',
          message: response.responseData?['message'] ?? 'Password reset successfully.',
        );

        // Clear sensitive data
        _email = '';
        otpCode.value = '';
        newPasswordController.clear();

        Get.offNamed(AppRoute.getLoginScreen());
      } else {
        AppLoggerHelper.error(
          '[ForgotPassword] Password reset failed | '
          'statusCode: ${response.statusCode} | error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Reset Failed',
          message: response.errorMessage,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[ForgotPassword] setNewPassword exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}

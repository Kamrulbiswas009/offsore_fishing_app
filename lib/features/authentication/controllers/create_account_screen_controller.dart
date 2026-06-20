import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/verify_email_otp_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class CreateAccountScreenController extends GetxController {
  static const int otpLength = 6;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpFieldController = OtpFieldController();
  final NetworkCaller _networkCaller = NetworkCaller();

  final isPasswordObscured = true.obs;
  final isConfirmPasswordObscured = true.obs;
  final otpCode = ''.obs;
  final hasOtpError = false.obs;

  String _registeredEmail = '';

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured.value = !isConfirmPasswordObscured.value;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required.';
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email address.';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }
    if (value != passwordController.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> createAccount() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    await EasyLoading.show(status: 'Creating account...');
    try {
      final response = await _networkCaller.postRequest(
        ApiConstants.createAccountApi,
        body: {'name': name, 'email': email, 'password': password},
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Create account failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Registration failed',
          message: response.errorMessage,
        );
        return;
      }

      _registeredEmail = email;
      final message = _responseMessage(
        response.responseData,
        'Registration successful. Please check your email.',
      );
      AppLoggerHelper.info('Create account success: $message');
      _clearRegistrationFields();
      CommonMessage.showMessage(title: 'Account created', message: message);
      Get.to(() => VerifyEmailOtpScreen());
    } catch (error) {
      AppLoggerHelper.error('Create account failed unexpectedly', error);
      CommonMessage.showMessage(
        title: 'Registration failed',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  void updateOtp(String value) {
    otpCode.value = value;
    if (value.length == otpLength) hasOtpError.value = false;
  }

  Future<void> verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (otpCode.value.length != otpLength) {
      hasOtpError.value = true;
      CommonMessage.showMessage(
        title: 'Invalid OTP',
        message: 'Please enter the $otpLength digit OTP sent to your email.',
      );
      return;
    }

    await EasyLoading.show(status: 'Verifying OTP...');
    try {
      final response = await _networkCaller.postRequest(
        ApiConstants.verifyEmailApi,
        body: {'email': _registeredEmail, 'otp': otpCode.value},
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'OTP verification failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Verification failed',
          message: response.errorMessage,
        );
        return;
      }

      final message = _responseMessage(
        response.responseData,
        'Email verified successfully.',
      );
      AppLoggerHelper.info('OTP verification success: $message');
      otpCode.value = '';
      hasOtpError.value = false;
      otpFieldController.clear();
      CommonMessage.showMessage(title: 'Email verified', message: message);
      Get.offAllNamed(AppRoute.getLoginScreen());
    } catch (error) {
      AppLoggerHelper.error('OTP verification failed unexpectedly', error);
      CommonMessage.showMessage(
        title: 'Verification failed',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  void backToLogin() => Get.offAllNamed(AppRoute.getLoginScreen());

  void continueWithGoogle() {}

  void continueWithApple() {}

  String _responseMessage(dynamic data, String fallback) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }

  void _clearRegistrationFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

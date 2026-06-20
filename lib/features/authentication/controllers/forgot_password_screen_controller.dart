import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
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

  void togglePasswordVisibility() {
    isNewPasswordObscured.value = !isNewPasswordObscured.value;
  }

  static const int otpLength = 4;

  void backToLogin() {
    Get.offNamed(AppRoute.getLoginScreen());
  }

  void sendOtp() {
    otpCode.value = '';
    hasOtpError.value = false;
    Get.to(() => VerifyOtpScreen());
  }

  void updateOtp(String value) {
    otpCode.value = value;
    if (value.length == otpLength) {
      hasOtpError.value = false;
    }
  }

  void verifyOtp() {
    if (otpCode.value.length != otpLength) {
      hasOtpError.value = true;
      CommonMessage.showMessage(
        title: "Invalid OTP",
        message: "Please enter the $otpLength digit OTP sent to your email.",
      );
      return;
    }

    hasOtpError.value = false;
    //otpFieldController.clear();
    CommonMessage.showMessage(
      title: "OTP Verified",
      message: "Your OTP has been verified successfully.",
    );
    Get.to(()=>SetNewPasswordScreen());
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

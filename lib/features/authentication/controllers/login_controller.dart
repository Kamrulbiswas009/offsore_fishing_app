import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/profile_main_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordObscured = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void login() {
    Get.to(()=>ProfileMainScreen());
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

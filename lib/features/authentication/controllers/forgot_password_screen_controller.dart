import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class ForgotPasswordScreenController extends GetxController {
  final emailController = TextEditingController();

  void backToLogin() {
    Get.offNamed(AppRoute.getLoginScreen());
  }

  void sendOtp() {}

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

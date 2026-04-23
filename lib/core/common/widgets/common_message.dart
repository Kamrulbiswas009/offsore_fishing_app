import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class CommonMessage {
  static void showMessage({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition? snackPosition,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor:
          backgroundColor ?? AppColors.blue00D4FF66Color.withValues(alpha: 0.4),
      colorText: colorText ?? Colors.white,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
    );
  }
}

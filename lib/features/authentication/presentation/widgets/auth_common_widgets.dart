import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/apple_login_controller.dart';

class AuthFieldLabel extends StatelessWidget {
  final String text;

  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: getTextStyle(
        color: AppColors.whiteE5E7EBColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        lineHeight: 10,
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: const Color(0xFF1C2B3C), height: 1.h),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            'Or continue with',
            style: getTextStyle(
              color: AppColors.grey8B95A5Color,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              lineHeight: 9,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: const Color(0xFF1C2B3C), height: 1.h),
        ),
      ],
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final bool isLoading;

  const AuthSocialButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43.h,
      child: CustomButton(
        ontap: isLoading ? null : onTap,
        title: title,
        bgColor: const Color(0xFF29303C),
        borderColor: AppColors.whiteColor.withValues(alpha: 0.10),
        borderRadius: 16.r,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        fontSize: 16,
        lineHeight: 10,
        titleColor: AppColors.whiteColor,
        prefixIcon: isLoading
            ? Padding(
                padding: EdgeInsets.only(right: 9.w),
                child: SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(right: 9.w),
                child: Image.asset(iconPath, width: 18.r, height: 18.r),
              ),
      ),
    );
  }
}

/// Clean UI Widget for Apple Sign-In that observes the [AppleLoginController]'s loading state
/// and displays a loading indicator during processing.
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final AppleLoginController? controller;

  const AppleSignInButton({
    super.key,
    this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final appleController = controller ?? Get.find<AppleLoginController>();
    return Obx(() {
      final isLoading = appleController.isLoading.value;
      return AuthSocialButton(
        title: 'Apple',
        iconPath: IconPath.appleIcon,
        onTap: onTap ?? appleController.continueWithApple,
        isLoading: isLoading,
      );
    });
  }
}


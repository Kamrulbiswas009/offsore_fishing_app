import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/forgot_password_screen_controller.dart';
import 'package:paytonpieper/features/authentication/presentation/widgets/auth_common_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final ForgotPasswordScreenController controller =
      Get.find<ForgotPasswordScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: controller.backToLogin,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 9.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: AppColors.grey8B95A5Color,
                          size: 17.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Back to Login',
                          style: getTextStyle(
                            color: AppColors.grey8B95A5Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            lineHeight: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 34.h),
              Image.asset(IconPath.paytonFishLogo, width: 61.w, height: 53.h),
              SizedBox(height: 25.h),
              Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  lineHeight: 20,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "No worries! Enter your email and we'll send\nyou a reset link.",
                textAlign: TextAlign.center,
                style: getTextStyle(
                  color: const Color(0xFFD4D8DF),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 24.h),
              const AuthFieldLabel('Email'),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: controller.emailController,
                hintText: 'your@email.com',
                prefixIcon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              const Spacer(),
              CustomButton(
                ontap: controller.sendOtp,
                title: 'Send  OTP',
                borderRadius: 7.r,
                // padding: EdgeInsets.zero,
                // fontSize: 14,
                // lineHeight: 10,
              ),
              SizedBox(height: 51.h),
            ],
          ),
        ),
      ),
    );
  }
}

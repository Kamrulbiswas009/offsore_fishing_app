import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/apple_login_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/google_login_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/login_controller.dart';
import 'package:paytonpieper/features/authentication/presentation/widgets/auth_common_widgets.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();
  final GoogleLoginController googleLoginController =
      Get.find<GoogleLoginController>();
  final AppleLoginController appleLoginController =
      Get.find<AppleLoginController>();
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    IconPath.paytonFishLogo,
                    width: 61.w,
                    height: 53.h,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      lineHeight: 20,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Log in to see the latest offshore intel',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      color: AppColors.grey8B95A5Color,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      lineHeight: 12,
                    ),
                  ),
                  SizedBox(height: 35.h),
                  const AuthFieldLabel('Email'),
                  SizedBox(height: 6.h),
                  CustomTextField(
                    controller: controller.emailController,
                    hintText: 'your@email.com',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                  ),
                  SizedBox(height: 12.h),
                  const AuthFieldLabel('Password'),
                  SizedBox(height: 6.h),
                  Obx(
                    () => CustomPasswordTextField(
                      controller: controller.passwordController,
                      obscureText: controller.isPasswordObscured.value,
                      onVisibilityTap: controller.togglePasswordVisibility,
                      textInputAction: TextInputAction.done,
                      validator: controller.validatePassword,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: controller.forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: getTextStyle(
                          color: const Color(0xFF117A88),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          lineHeight: 9,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    //height: 43.h,
                    child: CustomButton(
                      ontap: controller.login,
                      title: 'Log in',
                      borderRadius: 10.r,
                      //padding: EdgeInsets.zero,
                      fontSize: 16,
                      lineHeight: 12,
                    ),
                  ),
                  SizedBox(height: 39.h),
                  const AuthDivider(),
                  SizedBox(height: 31.h),
                  Row(
                    children: [
                      Expanded(
                        child: AuthSocialButton(
                          title: 'Google',
                          iconPath: IconPath.googleIcon,
                          onTap: googleLoginController.continueWithGoogle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppleSignInButton(
                          controller: appleLoginController,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 21.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: getTextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          lineHeight: 10,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Get.offNamed(AppRoute.getCreateAccountScreen()),
                        child: Text(
                          'Create Account',
                          style: getTextStyle(
                            color: const Color(0xFF117A88),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            lineHeight: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

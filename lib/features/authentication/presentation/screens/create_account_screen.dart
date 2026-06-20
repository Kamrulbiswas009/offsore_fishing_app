import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/create_account_screen_controller.dart';
import 'package:paytonpieper/features/authentication/presentation/widgets/auth_common_widgets.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class CreateAccountScreen extends StatelessWidget {
  final CreateAccountScreenController controller =
      Get.find<CreateAccountScreenController>();
  CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10.h),
                  Image.asset(
                    IconPath.paytonFishLogo,
                    width: 61.w,
                    height: 53.h,
                  ),
                  SizedBox(height: 26.h),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      lineHeight: 20,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Get offshore intel that actually helps',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      color: Color(0xFFDFE3E8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      lineHeight: 12,
                    ),
                  ),
                  SizedBox(height: 35.h),
                  const AuthFieldLabel('Name'),
                  SizedBox(height: 6.h),
                  CustomTextField(
                    controller: controller.nameController,
                    hintText: 'Your name',
                    prefixIcon: Icons.person_outline,
                    validator: controller.validateName,
                  ),
                  SizedBox(height: 12.h),
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
                      validator: controller.validatePassword,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const AuthFieldLabel('Confirm Password'),
                  SizedBox(height: 6.h),
                  Obx(
                    () => CustomPasswordTextField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.isConfirmPasswordObscured.value,
                      onVisibilityTap:
                          controller.toggleConfirmPasswordVisibility,
                      textInputAction: TextInputAction.done,
                      validator: controller.validateConfirmPassword,
                    ),
                  ),
                  SizedBox(height: 36.h),
                  SizedBox(
                    height: 42.h,
                    child: CustomButton(
                      ontap: controller.createAccount,
                      title: 'Create Account',
                      borderRadius: 10.r,
                      padding: EdgeInsets.zero,
                      fontSize: 16,
                      lineHeight: 12,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  const AuthDivider(),
                  SizedBox(height: 31.h),
                  Row(
                    children: [
                      Expanded(
                        child: AuthSocialButton(
                          title: 'Google',
                          iconPath: IconPath.googleIcon,
                          onTap: controller.continueWithGoogle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AuthSocialButton(
                          title: 'Apple',
                          iconPath: IconPath.appleIcon,
                          onTap: controller.continueWithApple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 21.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Do You have an account? ',
                        style: getTextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          lineHeight: 10,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.offNamed(AppRoute.getLoginScreen()),
                        child: Text(
                          'Log In Account',
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

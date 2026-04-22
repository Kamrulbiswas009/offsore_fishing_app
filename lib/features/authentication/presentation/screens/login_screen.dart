import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/login_controller.dart';
import 'package:paytonpieper/features/authentication/presentation/widgets/auth_common_widgets.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(IconPath.paytonFishLogo, width: 61.w, height: 53.h),
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
                  'Sign in to access real-time fishing intelligence',
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
                        color: const Color(0xFF00A6B4),
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
                    borderRadius: 7.r,
                    //padding: EdgeInsets.zero,
                    //fontSize: 14,
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
                      "Don't have an account? ",
                      style: getTextStyle(
                        color: AppColors.grey8B95A5Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        lineHeight: 9,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoute.getCreateAccountScreen()),
                      child: Text(
                        'Create Account',
                        style: getTextStyle(
                          color: const Color(0xFF00A6B4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          lineHeight: 9,
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
    );
  }
}

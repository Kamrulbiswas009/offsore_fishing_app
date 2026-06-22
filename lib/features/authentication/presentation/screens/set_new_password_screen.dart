import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/forgot_password_screen_controller.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/widgets/auth_common_widgets.dart';

class SetNewPasswordScreen extends StatelessWidget {
  final ForgotPasswordScreenController controller =
      Get.find<ForgotPasswordScreenController>();
  SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.all(20.r),
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
              SizedBox(height: 18.h),
              Text(
                "Set New Password",
                style: getTextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  lineHeight: 18,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 1),
              AuthFieldLabel("Password"),
              SizedBox(height: 6.h),
              Obx(
                () =>
              CustomPasswordTextField(
                controller: controller.newPasswordController,
                hintText: "Enter your new password",
                obscureText: controller.isNewPasswordObscured.value,
                textInputAction: TextInputAction.done,
                onVisibilityTap: () {
                  controller.togglePasswordVisibility();
                },
              ),),
              SizedBox(height: 16.h,),
              TextButton(
                onPressed: () {
                  Get.to(() => ForgotPasswordScreen());
                },
                child: Text(
                  "Resend Code",
                  style: getTextStyle(
                    color: AppColors.redDA605CColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    lineHeight: 10,
                  ),
                ),
              ),
              Spacer(flex: 2),
              Obx(
                () => CustomButton(
                  ontap: controller.isLoading.value
                      ? null
                      : () { controller.setNewPassword(); },
                  title: controller.isLoading.value ? 'Setting...' : 'Set New Password',
                ),
              ),
              SizedBox(height: 51.h),
            ],
          ),
        ),
      ),
    );
  }
}

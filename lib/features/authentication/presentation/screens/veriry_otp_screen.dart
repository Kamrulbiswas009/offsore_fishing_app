import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/authentication/controllers/forgot_password_screen_controller.dart';

class VeriryOtpScreen extends StatelessWidget {
  const VeriryOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordScreenController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
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
                "Verify OTP",
                style: getTextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  lineHeight: 18,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Give here the otp you received on your email",
                style: getTextStyle(
                  color: AppColors.grey8B95A5Color,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  lineHeight: 12,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Obx(
                () => OTPTextField(
                  controller: controller.otpFieldController,
                  length: ForgotPasswordScreenController.otpLength,
                  width: double.infinity,
                  fieldWidth: 50.w,
                  spaceBetween: 12.w,
                  fieldStyle: FieldStyle.box,
                  outlineBorderRadius: 8.r,
                  keyboardType: TextInputType.number,
                  textFieldAlignment: MainAxisAlignment.center,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  hasError: controller.hasOtpError.value,
                  otpFieldStyle: OtpFieldStyle(
                    backgroundColor: AppColors.grey8B95A5Color.withValues(
                      alpha: 0.2,
                    ),
                    borderColor: Colors.transparent,
                    enabledBorderColor: Colors.transparent,
                    focusBorderColor: AppColors.orangeColor,
                    errorBorderColor: AppColors.secondaryColor,
                    disabledBorderColor: Colors.transparent,
                  ),
                  style: getTextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    lineHeight: 18,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  onChanged: controller.updateOtp,
                  onCompleted: controller.updateOtp,
                ),
              ),
              Obx(
                () => controller.hasOtpError.value
                    ? Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          'Please enter the complete OTP.',
                          style: getTextStyle(
                            color: AppColors.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            lineHeight: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SizedBox(height: 22.h),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  ontap: controller.verifyOtp,
                  title: 'Verify OTP',
                  borderRadius: 12.r,
                  fontSize: 16,
                  lineHeight: 12,
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

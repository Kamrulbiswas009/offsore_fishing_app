import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

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

  const AuthSocialButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43.h,
      child: CustomButton(
        ontap: onTap,
        title: title,
        bgColor: const Color(0xFF29303C),
        borderColor: AppColors.whiteColor.withValues(alpha: 0.10),
        borderRadius: 16.r,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        fontSize: 16,
        lineHeight: 10,
        titleColor: AppColors.whiteColor,
        prefixIcon: Padding(
          padding: EdgeInsets.only(right: 9.w),
          child: Image.asset(iconPath, width: 18.r, height: 18.r),
        ),
      ),
    );
  }
}

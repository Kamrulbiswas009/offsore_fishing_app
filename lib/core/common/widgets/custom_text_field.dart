import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthTextFieldContainer(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: getTextStyle(
          color: AppColors.whiteColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          lineHeight: 20,
        ),
        cursorColor: AppColors.blue00F0FFColor,
        decoration: _inputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}

class CustomPasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback? onVisibilityTap;
  final TextInputAction textInputAction;

  const CustomPasswordTextField({
    super.key,
    required this.controller,
    this.hintText = '••••••••',
    this.obscureText = true,
    this.onVisibilityTap,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return _AuthTextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        obscuringCharacter: '•',
        textInputAction: textInputAction,
        style: getTextStyle(
          color: AppColors.whiteColor,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          lineHeight: 20,
        ),
        cursorColor: AppColors.blue00F0FFColor,
        decoration: _inputDecoration(
          hintText: hintText,
          prefixIcon: obscureText ? Icons.lock_outline : Icons.lock_open,
          suffixIcon: onVisibilityTap == null
              ? null
              : IconButton(
                  onPressed: onVisibilityTap,
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.grey8B95A5Color,
                    size: 18.r,
                  ),
                ),
        ),
      ),
    );
  }
}

class _AuthTextFieldContainer extends StatelessWidget {
  final Widget child;

  const _AuthTextFieldContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: child);
  }
}

InputDecoration _inputDecoration({
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFF29303C),
    hintText: hintText,
    hintStyle: getTextStyle(
      color: AppColors.grey8B95A5Color,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      lineHeight: 20,
    ),
    prefixIcon: Icon(prefixIcon, color: AppColors.grey8B95A5Color, size: 20.r),
    suffixIcon: suffixIcon,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11.r),
      borderSide: const BorderSide(color: Color(0xFF3B4351)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11.r),
      borderSide: const BorderSide(color: Color(0xFF3B4351)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11.r),
      borderSide: const BorderSide(color: Color(0xFF465163)),
    ),
  );
}

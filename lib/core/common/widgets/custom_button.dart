import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback ontap;
  final String title;
  final double? lineHeight;
  final double? fontSize;
  final Color? bgColor;
  final Color? borderColor;
  final Color? iconBgColor;
  final Color? titleColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  final Color? iconColor;

  const CustomButton({
    super.key,
    required this.ontap,
    required this.title,
    this.lineHeight,
    this.fontSize,
    this.bgColor,
    this.titleColor,
    this.suffixIcon,
    this.prefixIcon,
    this.iconColor,
    this.borderColor,
    this.iconBgColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final titleWidget = Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(
              fontSize: fontSize ?? 18,
              fontWeight: FontWeight.w500,
              color: titleColor ?? AppColors.whiteColor,
              lineHeight: lineHeight ?? 14,
            ),
          );

          return Container(
            padding: padding ?? EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.orangeColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 50.r),
              border: Border.all(
                color: borderColor ?? Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) prefixIcon ?? const SizedBox.shrink(),
                if (constraints.maxWidth.isFinite)
                  Flexible(child: titleWidget)
                else
                  titleWidget,
                if (suffixIcon != null) suffixIcon ?? const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }
}

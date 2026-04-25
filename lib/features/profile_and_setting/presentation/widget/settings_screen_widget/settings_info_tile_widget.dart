import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class SettingsInfoTileWidget extends StatelessWidget {
  final String title;
  final String? trailingText;
  final bool showDivider;
  final VoidCallback onTap;

  const SettingsInfoTileWidget({
    super.key,
    required this.title,
    this.trailingText,
    this.showDivider = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.tealColor117A88.withValues(alpha: 0.55),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 12,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey8B95A5Color,
                size: 22.r,
              ),
          ],
        ),
      ),
    );
  }
}

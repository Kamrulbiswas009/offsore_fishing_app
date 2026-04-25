import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class SettingsSwitchTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                  lineHeight: 12,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Transform.scale(
          scale: 0.80,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.whiteColor,
            activeTrackColor: AppColors.tealColor117A88,
            inactiveThumbColor: AppColors.whiteColor,
            inactiveTrackColor: AppColors.grey3A4B62Color,
          ),
        ),
      ],
    );
  }
}

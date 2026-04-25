import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class NotificationProBannerWidget extends StatelessWidget {
  const NotificationProBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.blue0D2B43Color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.blue00D4FF66Color.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Image.asset(IconPath.notificationTealIcon, width: 18.r, height: 18.r,),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Pro users get priority notifications',
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.whiteE5E7EBColor,
                lineHeight: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

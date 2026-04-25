import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/notification/controller/notification_screen_controller.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItemModel item;
  final bool showDivider;

  const NotificationItemWidget({
    super.key,
    required this.item,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppColors.blue00D4FF66Color.withValues(alpha: 0.45),
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.iconBackgroundColor,
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 18.r, color: item.iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                          lineHeight: 16,
                        ),
                      ),
                    ),
                    if (item.isUnread) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 7.r,
                        height: 7.r,
                        margin: EdgeInsets.only(top: 6.h),
                        decoration: const BoxDecoration(
                          color: AppColors.tealColor117A88,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: AppColors.black2A2F3AColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check_rounded,
                          size: 12.r,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  item.description,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.time,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

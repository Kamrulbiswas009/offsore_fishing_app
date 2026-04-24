import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class GroupCardWidget extends StatelessWidget {
  final String groupName;
  final String groupMember;
  final String description;
  final bool isLocked;
  final VoidCallback? onTap;
  const GroupCardWidget({
    super.key,
    required this.groupName,
    required this.groupMember,
    required this.description,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.black0F1E33Color,
          border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomBackButton(
                  bgColor: AppColors.orangeColor.withValues(alpha: 0.20),
                  icon: Image.asset(
                    IconPath.doublePersonIcon,
                    width: 24.r,
                    height: 24.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                          lineHeight: 12,
                        ),
                      ),
                      Text(
                        groupMember,
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey8B95A5Color,
                          lineHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if(isLocked == true)
                Image.asset(IconPath.lockIcon, width: 12.r, height: 12.r),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              description,
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
    );
  }
}

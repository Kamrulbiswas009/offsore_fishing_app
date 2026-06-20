import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class ProfileInfoCardWidget extends StatelessWidget {
  final String name;
  final String email;
  final String imagePath;
  final VoidCallback onEditTap;

  const ProfileInfoCardWidget({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors
            .containerBackgroundColor, // AppColors.black2A2F3AColor.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFF117E97)),
      ),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.whiteColor.withValues(alpha: 0.10),
              ),
            ),
            child: ClipOval(
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, color: AppColors.whiteColor),
                    )
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.whiteColor,
                          lineHeight: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onEditTap,
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: AppColors.black2A2F3AColor.withValues(
                            alpha: 0.60,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          IconPath.penIcon,
                          width: 18.r,
                          height: 18.r,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Image.asset(IconPath.mailIcon, width: 16.r, height: 16.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        email,
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey8B95A5Color,
                          lineHeight: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

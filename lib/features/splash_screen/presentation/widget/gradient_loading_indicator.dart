import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class GradientLoadingIndicator extends StatelessWidget {
  const GradientLoadingIndicator({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);

    return Container(
      width: 234.w,
      height: 7.h,
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: normalizedProgress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.r),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00D4FF),
                  Color(0xFF6BC9E6),
                  Color(0xFF94BECC),
                  Color(0xFFB1B1B2),
                  Color(0xFFC9A397),
                  Color(0xFFDD947B),
                  Color(0xFFEF815C),
                  Color(0xFFFF6B35),
                  Color(0xFFEF815C),
                  Color(0xFFDD947B),
                  Color(0xFFC9A397),
                  Color(0xFFB1B1B2),
                  Color(0xFF94BECC),
                  Color(0xFF6BC9E6),
                  Color(0xFF00D4FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue00D4FF66Color.withValues(alpha: 0.45),
                  blurRadius: 12.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

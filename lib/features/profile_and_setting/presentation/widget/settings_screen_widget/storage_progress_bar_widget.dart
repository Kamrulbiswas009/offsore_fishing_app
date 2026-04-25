import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';

class StorageProgressBarWidget extends StatelessWidget {
  final double progress;

  const StorageProgressBarWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0, 1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(99.r),
      child: Container(
        height: 8.h,
        width: double.infinity,
        color: AppColors.grey516173Color.withValues(alpha: 0.28),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: clampedProgress,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.blue00F0FFColor,
                    AppColors.orangeFF6B35Color,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

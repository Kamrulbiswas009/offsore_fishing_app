// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:paytonpieper/core/common/styles/global_text_style.dart';
// import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
// import 'package:paytonpieper/core/common/widgets/custom_button.dart';
// import 'package:paytonpieper/core/utils/constants/colors.dart';
// import 'package:paytonpieper/core/utils/constants/icon_path.dart';

// class JoinGroupCardWidget extends StatelessWidget {
//   final VoidCallback onTap;

//   const JoinGroupCardWidget({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12.r),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
//         child: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: AppColors.tealColor117A88, width: 1.2),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppColors.blue00D4FF66Color.withValues(alpha: 0.1),
//                 AppColors.orangeFF6B35Color.withValues(alpha: 0.2),
//               ],
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.blackColor.withValues(alpha: 0.18),
//                 blurRadius: 24,
//                 offset: const Offset(0, 12),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               // Positioned(
//               //   left: 0,
//               //   right: 0,
//               //   bottom: 0.h,
//               //   child: Center(
//               //     child: Container(
//               //       width: 200.w,
//               //       height: 80.h,
//               //       decoration: const BoxDecoration(
//               //         shape: BoxShape.circle,
//               //         gradient: RadialGradient(
//               //           colors: [Color(0x66FF6B35), Color(0x00FF6B35)],
//               //         ),
//               //       ),
//               //     ),
//               //   ),
//               // ),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 42.h),
//                 child: Column(
//                   children: [
//                     CustomBackButton(
//                       bgColor: AppColors.blue00D4FF66Color.withValues(
//                         alpha: 0.18,
//                       ),
//                       icon: Image.asset(
//                         IconPath.keyIcon,
//                         height: 24.h,
//                         width: 24.w,
//                       ),
//                     ),
//                     SizedBox(height: 14.h),
//                     Text(
//                       "Join with Code",
//                       textAlign: TextAlign.center,
//                       style: getTextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.whiteColor,
//                         lineHeight: 12,
//                       ),
//                     ),
//                     SizedBox(height: 3.h),
//                     Text(
//                       "Enter an invite code to join a group",
//                       textAlign: TextAlign.center,
//                       style: getTextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: AppColors.grey8B95A5Color,
//                         lineHeight: 10,
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.orangeFF6B35Color.withValues(
//                               alpha: 0.35,
//                             ),
//                             blurRadius: 28,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: CustomButton(
//                         ontap: onTap,
//                         title: "Join Group",
//                         bgColor: AppColors.orangeFF6B35Color,
//                         titleColor: AppColors.whiteColor,
//                         borderRadius: 6.r,
//                         // padding: EdgeInsets.symmetric(
//                         //   horizontal: 30.w,
//                         //   vertical: 12.h,
//                         // ),
//                         fontSize: 16,
//                         lineHeight: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';

class JoinGroupCardWidget extends StatelessWidget {
  final VoidCallback onTap;

  const JoinGroupCardWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.tealColor117A88, width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF00D4FF).withValues(alpha: 0.08),
                AppColors.orangeFF6B35Color.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Key icon circle button
                CustomBackButton(
                  bgColor: Color(0xFF00D4FF).withValues(alpha: 0.18),
                  icon: Image.asset(
                    IconPath.keyIcon,
                    height: 24.h,
                    width: 24.w,
                    color: Color(0xFF00D4FF),
                  ),
                ),

                SizedBox(height: 14.h),

                // Title
                Text(
                  "Join with Code",
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor,
                    lineHeight: 12,
                  ),
                ),

                SizedBox(height: 4.h),

                // Subtitle
                Text(
                  "Enter an invite code to join a group",
                  textAlign: TextAlign.center,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),

                SizedBox(height: 18.h),

                // Join Group button with orange glow
                Container(
                  //width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orangeFF6B35Color.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CustomButton(
                    ontap: onTap,
                    title: "Join Group",
                    bgColor: AppColors.orangeFF6B35Color,
                    titleColor: AppColors.whiteColor,
                    borderRadius: 6.r,
                    fontSize: 16,
                    lineHeight: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';

class JoinGroupBottomSheet extends GetView<GroupMainScreenController> {
  const JoinGroupBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardInset = mediaQuery.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF0F1E33),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(
                color: AppColors.tealColor117A88.withValues(alpha: 0.55),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              child: Obx(
                () => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'JOIN GROUP',
                                    style: getTextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.whiteColor,
                                      lineHeight: 12,
                                    ),
                                  ),
                                  //SizedBox(height: 4.h),
                                  Text(
                                    'Enter invite code',
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blue00D4FFColor,
                                      lineHeight: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CustomBackButton(
                              ontap: controller.closeJoinGroupSheet,
                              bgColor: AppColors.transparentColor,
                              icon: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.whiteColor.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.whiteColor,
                                  size: 18.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: AppColors.tealColor117A88),
                      Padding(
                        padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 24.h),
                        child: controller.hasJoinedGroup.value
                            ? const _JoinGroupSuccessContent()
                            : const _JoinGroupFormContent(),
                      ),
                      SizedBox(height: 60.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinGroupFormContent extends GetView<GroupMainScreenController> {
  const _JoinGroupFormContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.blue00D4FFColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.blue00D4FFColor.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                IconPath.lockTealColorIcon,
                height: 24.h,
                width: 24.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Private Group Access',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Get an invite code from a group admin to join their crew and access exclusive offshore intel.',
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
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'INVITE CODE',
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey8B95A5Color,
            lineHeight: 10,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.inviteCodeController,
          textCapitalization: TextCapitalization.characters,
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            lineHeight: 12,
          ),
          cursorColor: AppColors.blue00D4FFColor,
          decoration: InputDecoration(
            hintText: 'G1ABCD',
            hintStyle: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey8B95A5Color,
              lineHeight: 12,
            ),
            filled: true,
            fillColor: AppColors.black0F1E33Color,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 18.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.grey3A4B62Color),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.grey3A4B62Color),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: AppColors.blue00D4FFColor.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Enter the code exactly as shown',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.grey8B95A5Color,
            lineHeight: 10,
          ),
        ),
        SizedBox(height: 18.h),
        Obx(() {
          final bool isEnabled = controller.hasInviteCode.value;

          return Opacity(
            opacity: isEnabled ? 1 : 0.55,
            child: CustomButton(
              ontap: isEnabled ? controller.joinGroup : () {},
              title: 'Join Group',
              bgColor: isEnabled
                  ? AppColors.orangeColor
                  : AppColors.brown9D543DColor,
              titleColor: isEnabled
                  ? AppColors.whiteColor
                  : AppColors.grey8B95A5Color,
              borderRadius: 12.r,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  Icons.group_add_outlined,
                  color: isEnabled
                      ? AppColors.whiteColor
                      : AppColors.grey8B95A5Color,
                  size: 18.r,
                ),
              ),
              fontSize: 16,
              lineHeight: 12,
            ),
          );
        }),
        SizedBox(height: 18.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Color(0xFF0F1E33).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to get an invite code:',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Ask the group admin or a member for their invite code',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'They can find it in their group settings under "Invite Members"',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Enter the code above to request access',
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
      ],
    );
  }
}

class _JoinGroupSuccessContent extends GetView<GroupMainScreenController> {
  const _JoinGroupSuccessContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blue134D67Color.withValues(alpha: 0.75),
          ),
          child: Image.asset(
            IconPath.checkCircleBreakIcon,
            height: 48.r,
            width: 48.r,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Welcome Aboard!',
          textAlign: TextAlign.center,
          style: getTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            lineHeight: 14,
          ),
        ),
        SizedBox(height: 6.h),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "You've successfully joined ",
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.grey8B95A5Color,
              lineHeight: 12,
            ),
            children: [
              TextSpan(
                text: controller.joinedGroupName,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue00D4FFColor,
                  lineHeight: 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: AppColors.blue00D4FFColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.blue00D4FFColor.withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            'You now have access to exclusive fishing reports and can collaborate with your crew on offshore intelligence.',
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF5F6FD),
              lineHeight: 10,
            ),
          ),
        ),
        SizedBox(height: 60.h),
      ],
    );
  }
}

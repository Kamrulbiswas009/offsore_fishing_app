import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';

class GroupDetailsHeader extends GetView<GroupDetailsScreenController> {
  const GroupDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomBackButton(ontap: Get.back),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Image.asset(
                controller.groupImage,
                width: 56.r,
                height: 56.r,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.groupName,
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whiteColor,
                      lineHeight: 14,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${controller.groupMembers} · ${controller.groupCreatedBy}',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                      lineHeight: 10,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    controller.groupDescription,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteColor,
                      lineHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
    return Obx(() {
      final detail = controller.groupDetail.value;

      // Resolved display values: prefer API data, fall back to legacy fields.
      final name = detail?.name ?? controller.groupName;
      final memberCount = detail?.members.length ?? 0;
      final membersLabel =
          detail != null
              ? '$memberCount member${memberCount == 1 ? '' : 's'}'
              : controller.groupMembers;
      final ownerName =
          (detail != null && detail.ownerName.isNotEmpty)
              ? 'Created by ${detail.ownerName}'
              : controller.groupCreatedBy;
      final description = detail?.description ?? controller.groupDescription;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBackButton(ontap: Get.back),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group avatar — letter placeholder (no group image from API)
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: AppColors.tealColor117A88.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name.characters.first.toUpperCase() : 'G',
                  style: getTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tealColor117A88,
                    lineHeight: 16,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: getTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 14,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '$membersLabel · $ownerName',
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey8B95A5Color,
                        lineHeight: 10,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
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
    });
  }
}

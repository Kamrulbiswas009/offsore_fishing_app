import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
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
      final membersLabel = detail != null
          ? '$memberCount member${memberCount == 1 ? '' : 's'}'
          : controller.groupMembers;
      final ownerName = (detail != null && detail.ownerName.isNotEmpty)
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
                        lineHeight: 9,
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
              GestureDetector(
                onTap: () {
                  controller.groupNameTEController.text = name;
                  controller.groupDescriptionTEController.text = description;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: AppColors.backgroundDarkColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          side: BorderSide(
                            color: AppColors.whiteColor,
                            width: 1.w,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Update Group",
                                    style: getTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteColor,
                                      lineHeight: 12,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                "Group Name",
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.whiteColor,
                                  lineHeight: 10,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              TextField(
                                controller: controller.groupNameTEController,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.whiteColor,
                                  lineHeight: 10,
                                ),
                                decoration: InputDecoration(
                                  hintText: name,
                                  hintStyle: getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blue00D4FFColor,
                                    lineHeight: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.whiteColor,
                                      width: 1.w,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.whiteColor,
                                      width: 1.w,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "Group Description",
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.whiteColor,
                                  lineHeight: 10,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              TextField(
                                controller:
                                    controller.groupDescriptionTEController,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.whiteColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: description,
                                  hintStyle: getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.whiteColor,
                                    lineHeight: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.whiteColor,
                                      width: 1.w,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: AppColors.whiteColor,
                                      width: 1.w,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    title: "Update Group",
                                    fontSize: 12,
                                    lineHeight: 9,
                                    ontap: () {
                                      controller.updateGroup();
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Image.asset(IconPath.penIcon, height: 16.h, width: 16.w),
              ),
            ],
          ),
        ],
      );
    });
  }
}

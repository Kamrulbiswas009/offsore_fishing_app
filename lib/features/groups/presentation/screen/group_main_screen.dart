import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';
import 'package:paytonpieper/features/groups/model/group_model.dart';
import 'package:paytonpieper/features/groups/presentation/screen/create_group_screen.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/group_card_widget.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/join_group_bottom_sheet.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/join_group_card_widget.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class GroupMainScreen extends StatelessWidget {
  const GroupMainScreen({super.key});

  void _openJoinGroupSheet(BuildContext context) {
    final controller = Get.find<GroupMainScreenController>();
    controller.resetJoinGroupSheet();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      barrierColor: AppColors.blackColor.withValues(alpha: 0.55),
      builder: (_) => const JoinGroupBottomSheet(),
    );
  }

  void _navigateToGroupDetails(GroupListItem group) {
    final groupDetailsController = Get.find<GroupDetailsScreenController>();
    groupDetailsController.fetchGroupDetails(group.groupId);
    Get.toNamed(
      AppRoute.getGroupDetailsScreen(),
      arguments: {
        'groupId': group.groupId,
        'initialTab': 'members',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupMainScreenController>();

    return ColoredBox(
      color: AppColors.backgroundDarkColor,
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Groups",
                style: getTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteColor,
                  lineHeight: 16,
                ),
              ),
              Text(
                "Share offshore reports with the crew you trust",
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                ontap: () {
                  Get.to(() => CreateGroupScreen());
                },
                title: " Create Group",
                prefixIcon: Image.asset(
                  IconPath.addIcon,
                  width: 18.r,
                  height: 18.r,
                ),
                bgColor: AppColors.tealColor117A88,
                titleColor: AppColors.whiteColor,
              ),
              SizedBox(height: 24.h),
              JoinGroupCardWidget(onTap: () => _openJoinGroupSheet(context)),
              SizedBox(height: 15.h),
              Text(
                "My Groups",
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 12,
                ),
              ),
              SizedBox(height: 10.h),
          
              // ── Group list ──────────────────────────────────────────────
              Obx(() {
                // While loading → spinner with padding
                if (controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: CircularProgressIndicator(
                        color: AppColors.tealColor117A88,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                // Empty state
                if (controller.groupList.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "No groups yet. Create or join one!",
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey8B95A5Color,
                          lineHeight: 10,
                        ),
                      ),
                    ),
                  );
                }

                // Group cards — shrinkWrap so the ListView sizes to its content
                // inside SingleChildScrollView
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 80.h),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.groupList.length,
                  itemBuilder: (context, index) {
                    final group = controller.groupList[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: GroupCardWidget(
                        onTap: () => _navigateToGroupDetails(group),
                        groupName: group.name,
                        groupMember:
                            '${group.count.members} member${group.count.members == 1 ? '' : 's'}',
                        description: group.description,
                        isLocked: group.isPrivate,
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

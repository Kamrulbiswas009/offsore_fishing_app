import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/see_my_invitation_controller.dart';
import 'package:paytonpieper/features/groups/model/group_model.dart';
import 'package:paytonpieper/features/groups/presentation/screen/create_group_screen.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/group_card_widget.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/join_group_bottom_sheet.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/join_group_card_widget.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/see_my_invitation_widget.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class GroupMainScreen extends StatelessWidget {
  final GroupMainScreenController controller =
      Get.find<GroupMainScreenController>();
  final SeeMyInvitationController seeMyInvitationController =
      Get.find<SeeMyInvitationController>();
  GroupMainScreen({super.key});

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
      arguments: {'groupId': group.groupId, 'initialTab': 'members'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: Padding(
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
              //Here show all my invitation-
              if(seeMyInvitationController.invitations.isNotEmpty) ...[
              Text(
                "Requested Invitations",
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 12,
                ),
              ),
              SizedBox(height: 10.h),],
              Obx(() {
                if (seeMyInvitationController.invitations.isEmpty) {
                  return SizedBox.shrink();
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: seeMyInvitationController.invitations.length,
                  itemBuilder: (context, index) {
                    final invitation =
                        seeMyInvitationController.invitations[index];
                    return SeeMyInvitationWidget(
                      seeMyInvitationController: seeMyInvitationController,
                      invitation: invitation,
                    );
                  },
                );
              }),

              SizedBox(height: 16.h),
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
                      child: GestureDetector(
                        onLongPress: () {
                          //if user
                          if (group.createdBy == StorageService.userId) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor:
                                      AppColors.backgroundDarkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: AppColors.grey8B95A5Color,
                                      width: 1,
                                    ),
                                  ),
                                  title: Text(
                                    "Delete Group",
                                    style: getTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteColor,
                                      lineHeight: 12,
                                    ),
                                  ),
                                  content: Text(
                                    "Are you sure you want to delete this group?",
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.grey8B95A5Color,
                                      lineHeight: 10,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        controller.deleteGroup(group.groupId);
                                        Get.back();
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor:
                                      AppColors.backgroundDarkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: AppColors.grey8B95A5Color,
                                      width: 1,
                                    ),
                                  ),
                                  title: Text(
                                    "You are not owner of this group",
                                    style: getTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteColor,
                                      lineHeight: 12,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: GroupCardWidget(
                          onTap: () => _navigateToGroupDetails(group),
                          groupName: group.name,
                          groupMember:
                              '${group.count.members} member${group.count.members == 1 ? '' : 's'}',
                          description: group.description,
                          isLocked: group.isPrivate,
                        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_details_screen_widget/group_details_chat_tab.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_details_screen_widget/group_details_header.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_details_screen_widget/group_details_members_tab.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_details_screen_widget/group_details_reports_tab.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_details_screen_widget/group_details_tab_bar.dart';

class GroupDetailsScreen extends StatelessWidget {
  final GroupDetailsScreenController controller =
      Get.find<GroupDetailsScreenController>();

  GroupDetailsScreen({super.key}) {
    // setGroupDetails reads from controller.groupDetail if already fetched,
    // then falls back to any arguments passed.
    controller.setGroupDetails(Get.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Column(
            children: [
              const GroupDetailsHeader(),
              SizedBox(height: 18.h),
              const GroupDetailsTabBar(),
              SizedBox(height: 14.h),
              Expanded(
                child: Obx(() => _buildTabBody(controller.selectedTab.value)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody(GroupDetailsTab tab) {
    switch (tab) {
      case GroupDetailsTab.reports:
        return const GroupDetailsReportsTab();
      case GroupDetailsTab.chat:
        return const GroupDetailsChatTab();
      case GroupDetailsTab.members:
        return const GroupDetailsMembersTab();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';
import 'package:paytonpieper/features/groups/presentation/screen/create_group_screen.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/group_card_widget.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/join_group_bottom_sheet.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_main_screen_widget/join_group_card_widget.dart';
import 'package:paytonpieper/routes/app_routes.dart';

class GroupMainScreen extends StatelessWidget {
  final GroupMainScreenController controller =
      Get.find<GroupMainScreenController>();
  GroupMainScreen({super.key});

  void _openJoinGroupSheet(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarkColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
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
                  "A network built around the love of fishing",
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
                GroupCardWidget(
                  onTap: () {
                    Get.toNamed(
                      AppRoute.getGroupDetailsScreen(),
                      arguments: {
                        'initialTab': 'chat',
                        'groupName': 'Miami Offshore Crew',
                        'groupMembers': '24 members',
                        'groupCreatedBy': 'Created by Captain Mike',
                        'groupDescription':
                            'South Florida offshore fishing community',
                        'groupImage': ImagePath.miamiOffShoreCrewImage,
                      },
                    );
                  },
                  groupName: 'Miami Offshore Crew',
                  groupMember: '24 members',
                  description: 'South Florida offshore fishing community',
                  isLocked: false,
                ),
                SizedBox(height: 10.h),
                GroupCardWidget(
                  groupName: 'Keys Anglers',
                  groupMember: '56 members',
                  description: 'Florida offshore fishing community',
                  isLocked: true,
                ),
                SizedBox(height: 60.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

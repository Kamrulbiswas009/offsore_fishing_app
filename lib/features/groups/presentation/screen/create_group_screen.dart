import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/authentication/presentation/widgets/auth_common_widgets.dart';
import 'package:paytonpieper/features/groups/controller/create_group_screen_controller.dart';

class CreateGroupScreen extends StatelessWidget {
  final CreateGroupScreenController controller =
      Get.find<CreateGroupScreenController>();
  CreateGroupScreen({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBackButton(
                  bgColor: AppColors.black2A2F3AColor,
                  ontap: () {
                    Get.back();
                  },
                ),
                SizedBox(height: 18.h),
                Text(
                  "Create Group",
                  style: getTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                    lineHeight: 16,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Start a private fishing community",
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),
                SizedBox(height: 20.h),
                const AuthFieldLabel("Group Name *"),
                SizedBox(height: 8.h),
                CustomTextField(
                  fillColor: Color(0x14FFFFFF),
                  controller: controller.groupNameTEController,
                  hintText: "Miami Offshore Crew",
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 14.h),
                const AuthFieldLabel("Description"),
                SizedBox(height: 8.h),
                CustomTextField(
                  fillColor: Color(0x14FFFFFF),
                  controller: controller.groupDescriptionTEController,
                  hintText: "Brief description of your group...",
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3,
                  maxLines: 4,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    ontap: () {
                      //create group method will be called here
                    },
                    title: "Create Group",
                    borderRadius: 10.r,
                    bgColor: AppColors.orangeFF6B35Color,
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

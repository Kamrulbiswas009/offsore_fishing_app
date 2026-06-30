import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
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
                  "Create a private group for your trusted crew",
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.black2A2F3AColor,
                          backgroundImage: controller.groupImage != null
                              ? FileImage(controller.groupImage!)
                              : null,
                          child: controller.groupImage == null
                              ? Icon(
                                  Icons.group,
                                  size: 40.r,
                                  color: AppColors.grey8B95A5Color,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final image = await controller.pickImage();
                              if (image != null) {
                                controller.groupImage = image;
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: AppColors.orangeFF6B35Color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.backgroundDarkColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20.r,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                const AuthFieldLabel("Group Name *"),
                SizedBox(height: 8.h),
                CustomTextField(
                  fillColor: Color(0x14FFFFFF),
                  controller: controller.groupNameTEController,
                  hintText: "Enter your group's name",
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 14.h),
                const AuthFieldLabel("Description *"),
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
                      controller.createGroup();
                    },
                    title: "Create Group",
                    borderRadius: 10.r,
                    bgColor: AppColors.orangeFF6B35Color,
                    fontSize: 16,
                    lineHeight: 12,
                  ),
                ),
                SizedBox(height: 50.h),
                //Spacer(flex: 1,),
                Container(
                  padding: EdgeInsets.all(17.r),
                  decoration: BoxDecoration(
                    color: Color(0xFF00D4FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Color(0xFF00D4FF).withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(IconPath.infoIcon, width: 24.r, height: 24.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          "Only invited members can see group reports, chat, and crew activity.",
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFF5F6FD),
                            lineHeight: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

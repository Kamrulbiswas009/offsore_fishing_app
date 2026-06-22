import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';

class EditProfileDialog extends StatelessWidget {
  final ProfileMainScreenController controller;

  const EditProfileDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.containerBackgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFF117E97).withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C98AF).withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0C98AF).withValues(alpha: 0.20),
                    const Color(0xFF117E97).withValues(alpha: 0.10),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C98AF).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Image.asset(
                      IconPath.penIcon,
                      width: 16.r,
                      height: 16.r,
                      color: const Color(0xFF0C98AF),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.black2A2F3AColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.grey8B95A5Color,
                        size: 16.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar + pick image button
                  Center(
                    child: Obx(() {
                      final pickedFile = controller.selectedImageFile.value;
                      final networkImage = controller.profileImagePath;

                      return Column(
                        children: [
                          Container(
                            width: 90.r,
                            height: 90.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0C98AF).withValues(
                                  alpha: 0.6,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0C98AF,
                                  ).withValues(alpha: 0.20),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildAvatarImage(
                                pickedFile: pickedFile,
                                networkPath: networkImage,
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // Add / Change Image button
                          GestureDetector(
                            onTap: controller.pickProfileImage,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 9.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0C98AF),
                                    Color(0xFF117A88),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF0C98AF,
                                    ).withValues(alpha: 0.30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.whiteColor,
                                    size: 16.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    pickedFile != null
                                        ? 'Change Image'
                                        : 'Add Image',
                                    style: getTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.whiteColor,
                                      lineHeight: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  SizedBox(height: 24.h),

                  // Name label
                  Text(
                    'Full Name',
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyC8D0DBColor,
                      lineHeight: 10,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 8.h),

                  // Name text field
                  TextField(
                    controller: controller.editNameController,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                      lineHeight: 10,
                    ),
                    cursorColor: const Color(0xFF0C98AF),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey8B95A5Color,
                        lineHeight: 10,
                      ),
                      filled: true,
                      fillColor: AppColors.black2A2F3AColor,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: const Color(0xFF0C98AF),
                          size: 18.r,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.grey3A4B62Color.withValues(
                            alpha: 0.5,
                          ),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF0C98AF),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Action buttons
                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: GestureDetector(
                          onTap: Get.back,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            decoration: BoxDecoration(
                              color: AppColors.black2A2F3AColor,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.grey3A4B62Color.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greyC8D0DBColor,
                                lineHeight: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Update
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.updateProfile,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0C98AF),
                                  Color(0xFF117A88),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0C98AF,
                                  ).withValues(alpha: 0.30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Update',
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                                lineHeight: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage({File? pickedFile, required String networkPath}) {
    if (pickedFile != null) {
      return Image.file(pickedFile, fit: BoxFit.cover);
    }
    if (networkPath.startsWith('http')) {
      return Image.network(
        networkPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholderIcon(),
      );
    }
    if (networkPath.isNotEmpty) {
      return Image.asset(networkPath, fit: BoxFit.cover);
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(
      color: AppColors.black2A2F3AColor,
      child: const Icon(Icons.person, color: AppColors.grey8B95A5Color),
    );
  }
}

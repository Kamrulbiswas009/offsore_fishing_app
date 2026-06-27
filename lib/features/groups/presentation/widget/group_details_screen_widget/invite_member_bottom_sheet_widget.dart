import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_back_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/common/widgets/custom_text_field.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/model/group_details_model.dart';

class InviteMemberBottomSheetWidget
    extends GetView<GroupDetailsScreenController> {
  const InviteMemberBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double keyboardInset = mediaQuery.viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF0F1E33),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(
                color: AppColors.tealColor117A88.withValues(alpha: 0.55),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              child: SingleChildScrollView(
                controller: controller.inviteFriendsScrollController,
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 12.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'INVITE MEMBERS',
                                    style: getTextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.whiteColor,
                                      lineHeight: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    controller.groupName,
                                    style: getTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blue00D4FFColor,
                                      lineHeight: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CustomBackButton(
                              ontap: () =>
                                  controller.closeInviteMembersSheet(context),
                              bgColor: AppColors.transparentColor,
                              icon: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.whiteColor.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.whiteColor,
                                  size: 18.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: AppColors.tealColor117A88),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'INVITE METHOD',
                              style: getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey8B95A5Color,
                                lineHeight: 10,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _InviteMethodCard(
                                    method: GroupInviteMethod.friends,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: _InviteMethodCard(
                                    method: GroupInviteMethod.code,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: 0.48.sw,
                              child: const _InviteMethodCard(
                                method: GroupInviteMethod.email,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            _InviteMethodContent(
                              method: controller.selectedInviteMethod.value,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteMethodCard extends GetView<GroupDetailsScreenController> {
  final GroupInviteMethod method;

  const _InviteMethodCard({required this.method});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSelected = controller.selectedInviteMethod.value == method;

      return GestureDetector(
        onTap: () => controller.selectInviteMethod(method),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.blue00D4FFColor
                : AppColors.transparentColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.blue00D4FFColor
                  : AppColors.grey3A4B62Color,
            ),
          ),
          child: Column(
            children: [
              Image.asset(
                _iconPath,
                width: 16.r,
                height: 16.r,
                color: AppColors.whiteColor,
              ),
              SizedBox(height: 7.h),
              Text(
                _title,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteColor,
                  lineHeight: 10,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String get _title => switch (method) {
    GroupInviteMethod.friends => 'Friends',
    GroupInviteMethod.code => 'Code',
    GroupInviteMethod.email => 'Email',
  };

  String get _iconPath => switch (method) {
    GroupInviteMethod.friends => IconPath.doublePersonWhiteIcon,
    GroupInviteMethod.code => IconPath.lockIcon,
    GroupInviteMethod.email => IconPath.mailIcon,
  };
}

class _InviteMethodContent extends StatelessWidget {
  final GroupInviteMethod method;

  const _InviteMethodContent({required this.method});

  @override
  Widget build(BuildContext context) {
    switch (method) {
      case GroupInviteMethod.friends:
        return const _FriendsInviteContent();
      case GroupInviteMethod.code:
        return const _CodeInviteContent();
      case GroupInviteMethod.email:
        return const _EmailInviteContent();
    }
  }
}

class _FriendsInviteContent extends GetView<GroupDetailsScreenController> {
  const _FriendsInviteContent();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasSelection = controller.selectedFriendIds.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //here show a search box for searching friends
          CustomTextField(
            controller: controller.searchUserTEController,
            hintText: "Search with name or email",
            prefixIcon: Icons.search,
          ),
          SizedBox(height: 8.h),
          Text(
            'SELECT FRIENDS',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey8B95A5Color,
              lineHeight: 10,
            ),
          ),
          SizedBox(height: 12.h),
          if (controller.invitableFriends.isEmpty &&
              !controller.isPaginationLoading.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'No users found',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),
              ),
            ),
          ...controller.invitableFriends.map(
            (friend) => _FriendSelectionTile(friend: friend),
          ),
          if (controller.isPaginationLoading.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue00D4FFColor,
                ),
              ),
            ),
          SizedBox(height: 14.h),
          Opacity(
            opacity: hasSelection ? 1 : 0.55,
            child: CustomButton(
              ontap: hasSelection ? controller.inviteSelectedFriends : () {},
              title: ' Invite Friends',
              fontSize: 18,
              lineHeight: 12,
              bgColor: hasSelection
                  ? AppColors.orangeFF6B35Color
                  : AppColors.brown9D543DColor,
              titleColor: hasSelection
                  ? AppColors.whiteColor
                  : AppColors.grey8B95A5Color,
              borderRadius: 12,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Image.asset(
                  IconPath.doublePersonWhiteIcon,
                  width: 18.r,
                  height: 18.r,
                  color: hasSelection
                      ? AppColors.whiteColor
                      : AppColors.grey8B95A5Color,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _FriendSelectionTile extends GetView<GroupDetailsScreenController> {
  final InvitableFriendItem friend;

  const _FriendSelectionTile({required this.friend});

  Widget _buildAvatar() {
    if (friend.profileImage != null && friend.profileImage!.isNotEmpty) {
      return Image.network(
        friend.profileImage!,
        width: 44.r,
        height: 44.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _LetterAvatar(name: friend.name, size: 44.r),
      );
    } else if (friend.avatarPath.isNotEmpty) {
      return Image.asset(
        friend.avatarPath,
        width: 44.r,
        height: 44.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _LetterAvatar(name: friend.name, size: 44.r),
      );
    } else {
      return _LetterAvatar(name: friend.name, size: 44.r);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSelected = controller.isFriendSelected(friend.id);

      return GestureDetector(
        onTap: () => controller.toggleFriendSelection(friend.id),
        child: Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            children: [
              Container(
                width: 16.r,
                height: 16.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.blue00D4FFColor
                      : AppColors.transparentColor,
                  borderRadius: BorderRadius.circular(3.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.blue00D4FFColor
                        : AppColors.grey8B95A5Color,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, color: AppColors.whiteColor, size: 12.r)
                    : null,
              ),
              SizedBox(width: 12.w),
              ClipRRect(
                borderRadius: BorderRadius.circular(22.r),
                child: _buildAvatar(),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      friend.email ?? friend.subtitle,
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey8B95A5Color,
                        lineHeight: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _LetterAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _LetterAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.tealColor117A88,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: getTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
          lineHeight: 12,
        ),
      ),
    );
  }
}

class _CodeInviteContent extends GetView<GroupDetailsScreenController> {
  const _CodeInviteContent();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCodeEmpty = controller.inviteCode.value.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'INVITE CODE',
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey8B95A5Color,
              lineHeight: 10,
            ),
          ),
          SizedBox(height: 12.h),
          if (isCodeEmpty) ...[
            CustomButton(
              title: 'Generate Code',
              fontSize: 18,
              lineHeight: 12,
              bgColor: AppColors.orangeFF6B35Color,
              borderRadius: 12,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              ontap: () => controller.inviteWithCode(),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue00D4FFColor.withValues(alpha: 0.1),
                    AppColors.orangeFF6B35Color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.blue00D4FFColor.withValues(alpha: 0.55),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    controller.inviteCode.value,
                    style: getTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor,
                      lineHeight: 18,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Share this code with crew members',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                      lineHeight: 9,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Members can join by entering this code in the Groups section under "Join with Code"',
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.grey8B95A5Color,
                lineHeight: 10,
              ),
            ),
            SizedBox(height: 16.h),
            CustomButton(
              ontap: controller.copyInviteCode,
              title: ' Copy Code',
              fontSize: 18,
              lineHeight: 12,
              bgColor: AppColors.orangeFF6B35Color,
              borderRadius: 12,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  Icons.content_copy_rounded,
                  color: AppColors.whiteColor,
                  size: 18.r,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _EmailInviteContent extends GetView<GroupDetailsScreenController> {
  const _EmailInviteContent();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasEmails = controller.hasInviteEmails.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'EMAIL ADDRESSES',
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey8B95A5Color,
              lineHeight: 10,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.inviteEmailController,
            keyboardType: TextInputType.emailAddress,
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.whiteColor,
              lineHeight: 12,
            ),
            cursorColor: AppColors.blue00D4FFColor,
            decoration: InputDecoration(
              hintText: 'email@example.com',
              hintStyle: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.grey8B95A5Color,
                lineHeight: 12,
              ),
              filled: true,
              fillColor: AppColors.black0F1E33Color,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey3A4B62Color),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey3A4B62Color),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.blue00D4FFColor.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Separate multiple emails with commas',
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.grey8B95A5Color,
              lineHeight: 9,
            ),
          ),
          SizedBox(height: 16.h),
          Opacity(
            opacity: hasEmails ? 1 : 0.55,
            child: CustomButton(
              ontap: hasEmails ? controller.sendEmailInvites : () {},
              title: ' Send Invites',
              fontSize: 18,
              lineHeight: 12,
              bgColor: hasEmails
                  ? AppColors.orangeFF6B35Color
                  : AppColors.brown9D543DColor,
              titleColor: hasEmails
                  ? AppColors.whiteColor
                  : AppColors.grey8B95A5Color,
              borderRadius: 12,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Image.asset(
                  IconPath.mailIcon,
                  width: 18.r,
                  height: 18.r,
                  color: hasEmails
                      ? AppColors.whiteColor
                      : AppColors.grey8B95A5Color,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

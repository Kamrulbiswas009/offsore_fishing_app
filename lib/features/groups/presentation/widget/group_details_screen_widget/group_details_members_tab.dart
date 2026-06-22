import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/model/group_details_model.dart';
import 'package:paytonpieper/features/groups/model/group_model.dart';
import 'package:paytonpieper/features/groups/presentation/widget/group_details_screen_widget/invite_member_bottom_sheet_widget.dart';

class GroupDetailsMembersTab extends GetView<GroupDetailsScreenController> {
  const GroupDetailsMembersTab({super.key});

  void _openInviteMembersSheet(BuildContext context) {
    controller.resetInviteMembersSheet();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      barrierColor: AppColors.blackColor.withValues(alpha: 0.55),
      builder: (_) => const InviteMemberBottomSheetWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final apiDetail = controller.groupDetail.value;
      final apiMembers = apiDetail?.members ?? [];
      final hasFetched = apiDetail != null;

      return ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomButton(
            ontap: () => _openInviteMembersSheet(context),
            title: ' Invite Members',
            fontSize: 16,
            lineHeight: 13,
            bgColor: AppColors.orangeFF6B35Color,
            borderRadius: 12,
            prefixIcon: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Image.asset(
                IconPath.doublePersonWhiteIcon,
                width: 16.r,
                height: 16.r,
                color: AppColors.whiteColor,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Pending requests (static for now) ──────────────────────
          Text(
            'Pending Requests (${controller.pendingRequests.length})',
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteColor,
              lineHeight: 12,
            ),
          ),
          SizedBox(height: 12.h),
          ...controller.pendingRequests.map(
            (request) => _PendingRequestCard(request: request),
          ),
          SizedBox(height: 20.h),

          // ── Members from API ────────────────────────────────────────
          Text(
            hasFetched
                ? 'Members (${apiMembers.length})'
                : 'Members (${controller.members.length})',
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteColor,
              lineHeight: 12,
            ),
          ),
          SizedBox(height: 14.h),

          if (hasFetched)
            ...apiMembers.map((m) => _ApiMemberCard(member: m))
          else
            ...controller.members.map((m) => _MemberCard(member: m)),

          SizedBox(height: 20.h),
        ],
      );
    });
  }
}

// ── Pending request card (unchanged) ─────────────────────────────────────────
class _PendingRequestCard extends GetView<GroupDetailsScreenController> {
  final GroupMemberRequest request;
  const _PendingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.black0F1E33Color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey3A4B62Color),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: const BoxDecoration(
                  color: AppColors.tealColor117A88,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  request.name.characters.first,
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor,
                    lineHeight: 12,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.name,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    Text(
                      request.email,
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
              Text(
                request.timeAgo,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  ontap: () => controller.approveRequest(request),
                  title: 'Approve',
                  fontSize: 14,
                  lineHeight: 11,
                  bgColor: AppColors.blue00D4FFColor,
                  titleColor: AppColors.whiteColor,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: CustomButton(
                  ontap: () => controller.declineRequest(request),
                  title: 'Decline',
                  fontSize: 14,
                  lineHeight: 11,
                  bgColor: AppColors.transparentColor,
                  titleColor: AppColors.grey8B95A5Color,
                  borderColor: AppColors.grey8B95A5Color,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── API member card ───────────────────────────────────────────────────────────
class _ApiMemberCard extends StatelessWidget {
  final GroupDetailMember member;
  const _ApiMemberCard({required this.member});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = member.role == 'OWNER';
    final profileImageUrl = member.user.profileImage;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.black0F1E33Color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey3A4B62Color),
      ),
      child: Row(
        children: [
          // Avatar: network image if available, else letter placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child:
                (profileImageUrl != null && profileImageUrl.isNotEmpty)
                    ? Image.network(
                        profileImageUrl,
                        width: 44.r,
                        height: 44.r,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => _LetterAvatar(
                              name: member.user.name,
                              size: 44.r,
                            ),
                      )
                    : _LetterAvatar(name: member.user.name, size: 44.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.user.name,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    if (isOwner) ...[
                      SizedBox(width: 6.w),
                      Image.asset(
                        IconPath.crownIcon,
                        width: 14.r,
                        height: 14.r,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Joined ${_formatDate(member.joinedAt)}',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member.role,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 9,
                ),
              ),
              SizedBox(height: 4.h),
              // Report count placeholder (next time)
              Text(
                '– reports',
                style: getTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey8B95A5Color,
                  lineHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Letter avatar fallback ────────────────────────────────────────────────────
class _LetterAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _LetterAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final letter =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
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

// ── Static member card (fallback, unchanged) ──────────────────────────────────
class _MemberCard extends StatelessWidget {
  final GroupMemberItem member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.black0F1E33Color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey3A4B62Color),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: Image.asset(
              member.avatarPath,
              width: 44.r,
              height: 44.r,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    if (member.isLeader) ...[
                      SizedBox(width: 6.w),
                      Image.asset(
                        IconPath.crownIcon,
                        width: 14.r,
                        height: 14.r,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  member.subtitle,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            member.role,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.grey8B95A5Color,
              lineHeight: 9,
            ),
          ),
        ],
      ),
    );
  }
}

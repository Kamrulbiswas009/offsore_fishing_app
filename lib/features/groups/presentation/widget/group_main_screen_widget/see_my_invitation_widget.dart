import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/common/widgets/custom_button.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/groups/controller/see_my_invitation_controller.dart';
import 'package:paytonpieper/features/groups/model/group_invitation_model.dart';

class SeeMyInvitationWidget extends StatelessWidget {
  final SeeMyInvitationController seeMyInvitationController;
  final GroupInvitationModel invitation;

  const SeeMyInvitationWidget({
    super.key,
    required this.seeMyInvitationController,
    required this.invitation,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return 'GP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
    }
    return name.substring(0, name.length > 2 ? 2 : name.length).toUpperCase();
  }

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.isNegative) {
        return 'just now';
      }
      if (diff.inSeconds < 60) {
        return 'just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 30) {
        return '${diff.inDays}d ago';
      } else {
        return '${date.day} ${_getMonthName(date.month)}';
      }
    } catch (_) {
      return '';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
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
                width: 48.r,
                height: 48.r,
                decoration: const BoxDecoration(
                  color: AppColors.tealColor117A88,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(invitation.group.name),
                  style: getTextStyle(
                    fontSize: 14,
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
                      invitation.group.name,
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                        lineHeight: 12,
                      ),
                    ),
                    Text(
                      invitation.sender.name,
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
                _formatTimeAgo(invitation.createdAt),
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
                  ontap: () {
                    seeMyInvitationController.approveInvitation(invitation.id);
                  },
                  title: 'Join',
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
                  ontap: () {
                    seeMyInvitationController.rejectInvitation(invitation.id);
                  },
                  title: 'Reject',
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
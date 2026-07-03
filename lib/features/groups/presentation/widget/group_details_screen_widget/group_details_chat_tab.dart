import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/styles/global_text_style.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/groups/controller/message_service_controller.dart';
import 'package:paytonpieper/features/groups/model/group_details_model.dart';

class GroupDetailsChatTab extends GetView<MessageServiceController> {
  const GroupDetailsChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => ListView(
              controller: controller.scrollController,
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 18.h),
                Center(
                  child: Text(
                    controller.connectionStatus.value,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                      lineHeight: 10,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                ...controller.messages.map(
                  (message) => _MessageBubble(
                    message: message,
                    onLongPress: () => controller.startReply(message),
                  ),
                ),
                if (controller.typingUsers.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: 8.w, top: 4.h),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.asset(
                            ImagePath.messageProfileImage,
                            width: 28.r,
                            height: 28.r,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Typing...',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.grey8B95A5Color,
                            lineHeight: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
        Obx(() {
          final reply = controller.replyingTo.value;
          if (reply == null) return const SizedBox.shrink();

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 8.h, bottom: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.black0F1E33Color,
              borderRadius: BorderRadius.circular(10.r),
              border: Border(
                left: BorderSide(color: const Color(0xFF117E97), width: 3.w),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reply.isMine ? 'You' : reply.sender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteColor,
                          lineHeight: 10,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        reply.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.cancelReply,
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      Icons.close,
                      size: 16.r,
                      color: AppColors.grey8B95A5Color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Container(
          margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.black0F1E33Color,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: AppColors.whiteColor.withValues(alpha: 0.75),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.whiteColor,
                    lineHeight: 11,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message your crew...',
                    hintStyle: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                      lineHeight: 11,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
              Obx(
                () => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.isSending.value
                      ? null
                      : () => controller.sendMessage(),
                  child: SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: controller.isSending.value
                        ? CircularProgressIndicator(
                            strokeWidth: 2.r,
                            color: AppColors.whiteColor,
                          )
                        : Image.asset(
                            IconPath.messageSentIcon,
                            width: 22.r,
                            height: 22.r,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final GroupChatMessage message;
  final VoidCallback onLongPress;

  const _MessageBubble({required this.message, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    if (message.isMine) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.only(left: 70.w, bottom: 12.h),
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.black2A2F3AColor.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.r),
                      topRight: Radius.circular(10.r),
                      bottomLeft: Radius.circular(10.r),
                    ),
                  ),
                  child: _MessageContent(message: message),
                ),
                SizedBox(height: 4.h),
                Text(
                  message.time,
                  style: getTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey8B95A5Color,
                    lineHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: _MessageAvatar(
                imagePath: message.avatarPath,
                width: 28.r,
                height: 28.r,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.sender,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.whiteColor,
                      lineHeight: 10,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    constraints: BoxConstraints(maxWidth: 210.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF117E97),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.r),
                        topRight: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r),
                        //bottomLeft: Radius.circular(14.r),
                      ),
                    ),
                    child: _MessageContent(message: message),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message.time,
                    style: getTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                      lineHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageContent extends StatelessWidget {
  final GroupChatMessage message;

  const _MessageContent({required this.message});

  @override
  Widget build(BuildContext context) {
    final hasReply =
        (message.replySender?.isNotEmpty ?? false) ||
        (message.replyText?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasReply) ...[
          Container(
            constraints: BoxConstraints(maxWidth: 190.w),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.black0F1E33Color.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8.r),
              border: Border(
                left: BorderSide(color: AppColors.whiteColor, width: 2.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.replySender?.isNotEmpty ?? false)
                  Text(
                    message.replySender!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                      lineHeight: 9,
                    ),
                  ),
                if (message.replyText?.isNotEmpty ?? false)
                  Text(
                    message.replyText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey8B95A5Color,
                      lineHeight: 9,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
        ],
        Text(
          message.text,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.whiteColor,
            lineHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _MessageAvatar extends StatelessWidget {
  final String? imagePath;
  final double width;
  final double height;

  const _MessageAvatar({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath ?? ImagePath.messageProfileImage;
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          ImagePath.messageProfileImage,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      path.isEmpty ? ImagePath.messageProfileImage : path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        ImagePath.messageProfileImage,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}

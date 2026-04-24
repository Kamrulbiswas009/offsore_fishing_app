import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupMainScreenController extends GetxController {
  final TextEditingController inviteCodeController = TextEditingController();
  final RxBool hasInviteCode = false.obs;
  final RxBool hasJoinedGroup = false.obs;

  final String joinedGroupName = 'Miami Offshore Crew';

  @override
  void onInit() {
    super.onInit();
    inviteCodeController.addListener(_handleInviteCodeChanged);
  }

  void _handleInviteCodeChanged() {
    hasInviteCode.value = inviteCodeController.text.trim().isNotEmpty;
  }

  void joinGroup() {
    if (!hasInviteCode.value) {
      return;
    }

    hasJoinedGroup.value = true;
  }

  void closeJoinGroupSheet() {
    resetJoinGroupSheet();
    Get.back();
  }

  void resetJoinGroupSheet() {
    hasJoinedGroup.value = false;
    inviteCodeController.clear();
    hasInviteCode.value = false;
  }

  @override
  void onClose() {
    inviteCodeController
      ..removeListener(_handleInviteCodeChanged)
      ..dispose();
    super.onClose();
  }
}

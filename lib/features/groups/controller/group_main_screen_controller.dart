import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/groups/model/group_model.dart';

class GroupMainScreenController extends GetxController {
  // ── Join-group sheet state ──────────────────────────────────────────
  final TextEditingController inviteCodeController = TextEditingController();
  final RxBool hasInviteCode = false.obs;
  final RxBool hasJoinedGroup = false.obs;
  final String joinedGroupName = 'Miami Offshore Crew';

  // ── Group list API state ────────────────────────────────────────────
  final RxList<GroupListItem> groupList = <GroupListItem>[].obs;
  final RxBool isLoading = false.obs;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    inviteCodeController.addListener(_handleInviteCodeChanged);
    fetchGroupList();
  }

  // ── Fetch group list ────────────────────────────────────────────────
  Future<void> fetchGroupList() async {
    isLoading.value = true;

    try {
      final accessToken = StorageService.token;
      final token =
          (accessToken != null && accessToken.isNotEmpty)
              ? 'Bearer $accessToken'
              : null;

      final response = await _networkCaller.getRequest(
        ApiConstants.featchGroupListApi,
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupMain] fetchGroupList success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawList = body is Map ? body['data'] : null;
        if (rawList is List) {
          groupList.value = rawList
              .map(
                (e) => GroupListItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
      } else {
        AppLoggerHelper.error(
          '[GroupMain] fetchGroupList failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupMain] fetchGroupList exception', e);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Join-group sheet helpers ────────────────────────────────────────
  void _handleInviteCodeChanged() {
    hasInviteCode.value = inviteCodeController.text.trim().isNotEmpty;
  }

  void joinGroup() {
    if (!hasInviteCode.value) return;
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

  // ── Delete group ──────────────────────────────────────────────────
  Future<void> deleteGroup(String groupId) async {
    await EasyLoading.show(status: 'Deleting group...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.deleteRequest(
        ApiConstants.deleteGroupApi(groupId),
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupMain] deleteGroup success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        // Refresh group list on GroupMainScreen
        await fetchGroupList();

        // Close the dialog automatically
        if (Get.isOverlaysOpen) {
          Get.back();
        }

        CommonMessage.showMessage(
          title: 'Success',
          message: 'Group deleted successfully!',
        );
      } else {
        AppLoggerHelper.error(
          '[GroupMain] deleteGroup failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupMain] deleteGroup exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  @override
  void onClose() {
    inviteCodeController
      ..removeListener(_handleInviteCodeChanged)
      ..dispose();
    super.onClose();
  }
}

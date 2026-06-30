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
  final RxString joinedGroupName = 'Miami Offshore Crew'.obs;

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
    joinGroupWithCode();
  }

  // ── Join group with invite code ─────────────────────────────────────
  Future<void> joinGroupWithCode() async {
    final code = inviteCodeController.text.trim();
    if (code.isEmpty) return;

    await EasyLoading.show(status: 'Joining group...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      AppLoggerHelper.info(
        '[GroupMain] joinGroupWithCode | inviteCode: $code',
      );

      final response = await _networkCaller.postRequest(
        ApiConstants.joinGroupWithCodeApi,
        body: {'inviteCode': code},
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupMain] joinGroupWithCode success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        // Try to pick up a group name from the response for the success screen;
        // fall back gracefully if the field is absent.
        final data = body is Map ? body['data'] : null;
        final group = (data is Map ? data['group'] : null) as Map?;
        final groupName = (group != null ? group['name'] : null) as String?;
        if (groupName != null && groupName.isNotEmpty) {
          joinedGroupName.value = groupName;
        }

        hasJoinedGroup.value = true;

        // Refresh group list so the newly joined group appears immediately.
        await fetchGroupList();
      } else {
        AppLoggerHelper.error(
          '[GroupMain] joinGroupWithCode failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupMain] joinGroupWithCode exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
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

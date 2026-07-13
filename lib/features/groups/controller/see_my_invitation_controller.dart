import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/groups/model/group_invitation_model.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';

class SeeMyInvitationController extends GetxController {
  final RxList<GroupInvitationModel> invitations = <GroupInvitationModel>[].obs;
  final RxBool isLoading = false.obs;
  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    seeMyInvitations();
  }

  Future<void> seeMyInvitations({bool showHUD = true}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (showHUD) {
      EasyLoading.show(status: 'Loading invitations...');
    }
    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.getRequest(
        ApiConstants.seeMyInvitationApi,
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[SeeMyInvitation] seeMyInvitations success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawList = body is Map ? body['data'] : null;
        if (rawList is List) {
          invitations.value = rawList
              .map((e) => GroupInvitationModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          invitations.clear();
        }
      } else {
        AppLoggerHelper.error(
          '[SeeMyInvitation] seeMyInvitations failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Error',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[SeeMyInvitation] seeMyInvitations exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
      if (showHUD) {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> approveInvitation(String inviteId) async {
    EasyLoading.show(status: 'Approving invitation...');
    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.postRequest(
        ApiConstants.approveInvitationApi(inviteId),
        body: {},
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          '[SeeMyInvitation] approveInvitation success | '
          'statusCode: ${response.statusCode}',
        );

        CommonMessage.showMessage(
          title: 'Success',
          message: 'Invitation approved successfully',
        );

        // Remove invitation from current list
        invitations.removeWhere((item) => item.id == inviteId);

        // Fetch groups list again to show the newly joined group
        if (Get.isRegistered<GroupMainScreenController>()) {
          Get.find<GroupMainScreenController>().fetchGroupList();
        }
      } else {
        AppLoggerHelper.error(
          '[SeeMyInvitation] approveInvitation failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[SeeMyInvitation] approveInvitation exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> rejectInvitation(String inviteId) async {
    EasyLoading.show(status: 'Declining invitation...');
    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.postRequest(
        ApiConstants.rejectInvitationApi(inviteId),
        body: {},
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          '[SeeMyInvitation] rejectInvitation success | '
          'statusCode: ${response.statusCode}',
        );

        CommonMessage.showMessage(
          title: 'Success',
          message: 'Invitation declined successfully',
        );

        // Remove invitation from current list
        invitations.removeWhere((item) => item.id == inviteId);
      } else {
        AppLoggerHelper.error(
          '[SeeMyInvitation] rejectInvitation failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[SeeMyInvitation] rejectInvitation exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      EasyLoading.dismiss();
    }
  }
}
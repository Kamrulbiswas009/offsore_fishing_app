import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';

class CreateGroupScreenController extends GetxController {
  final TextEditingController groupNameTEController = TextEditingController();
  final TextEditingController groupDescriptionTEController =
      TextEditingController();

  final RxBool isFormValid = false.obs;
  final Rxn<File> _groupImage = Rxn<File>();

  File? get groupImage => _groupImage.value;
  set groupImage(File? value) => _groupImage.value = value;

  final NetworkCaller _networkCaller = NetworkCaller();

  @override
  void onInit() {
    super.onInit();
    groupNameTEController.addListener(_handleFormChanged);
    groupDescriptionTEController.addListener(_handleFormChanged);
  }

  void _handleFormChanged() {
    isFormValid.value =
        groupNameTEController.text.trim().isNotEmpty &&
        groupDescriptionTEController.text.trim().isNotEmpty;
  }

  Future<File?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      AppLoggerHelper.error('[CreateGroupController] pickImage exception', e);
    }
    return null;
  }

  Future<void> createGroup() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!isFormValid.value) {
      CommonMessage.showMessage(
        title: 'Required',
        message: 'Please fill in the group name and description.',
      );
      return;
    }

    await EasyLoading.show(status: 'Creating group...');

    try {
      final accessToken = StorageService.token;
      final token =
          (accessToken != null && accessToken.isNotEmpty)
              ? 'Bearer $accessToken'
              : null;

      final response = await _networkCaller.postMultipartRequest(
        ApiConstants.createNewGroupApi,
        fields: {
          'name': groupNameTEController.text.trim(),
          'description': groupDescriptionTEController.text.trim(),
          'isPrivate': 'true',
        },
        file: groupImage,
        fileFieldName: 'photo',
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[CreateGroup] createGroup success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        // Clear form
        groupNameTEController.clear();
        groupDescriptionTEController.clear();
        groupImage = null;

        // Refresh group list on GroupMainScreen
        if (Get.isRegistered<GroupMainScreenController>()) {
          Get.find<GroupMainScreenController>().fetchGroupList();
        }

        // Go back to GroupMainScreen
        Get.back();

        CommonMessage.showMessage(
          title: 'Success',
          message: 'Group created successfully!',
        );
      } else {
        AppLoggerHelper.error(
          '[CreateGroup] createGroup failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[CreateGroup] createGroup exception', e);
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
    groupNameTEController.removeListener(_handleFormChanged);
    groupDescriptionTEController.removeListener(_handleFormChanged);
    groupNameTEController.dispose();
    groupDescriptionTEController.dispose();
    super.onClose();
  }
}


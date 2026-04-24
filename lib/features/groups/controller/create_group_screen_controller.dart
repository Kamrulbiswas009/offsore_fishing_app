import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CreateGroupScreenController extends GetxController {
  final TextEditingController groupNameTEController = TextEditingController();
  final TextEditingController groupDescriptionTEController =
      TextEditingController();

  final RxBool isFormValid = false.obs;

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

  void createGroup() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!isFormValid.value) {
      return;
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

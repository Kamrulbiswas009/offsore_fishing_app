import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/success_submit_report/screen/succes_screen.dart';

class VisibilitySharingController extends GetxController {
  // Selection States
  var isPublicSelected = false.obs;
  var selectedGroups = <int>[].obs; // Stores IDs of selected groups

  // Mock Groups Data
  final List<Map<String, dynamic>> privateGroups = [
    {"id": 1, "name": "Miami Offshore Crew", "members": 24},
    {"id": 2, "name": "Keys Anglers", "members": 56},
    {"id": 3, "name": "Tournament Team", "members": 8},
  ];

  void togglePublic() => isPublicSelected.value = !isPublicSelected.value;

  void toggleGroup(int id) {
    if (selectedGroups.contains(id)) {
      selectedGroups.remove(id);
    } else {
      selectedGroups.add(id);
    }
  }

  bool get hasSelection => isPublicSelected.value || selectedGroups.isNotEmpty;

  void submitReport() {
    Get.to(() => const ReportSuccessScreen());
    // if (!hasSelection) {
    //   Get.snackbar("Error", "Please select at least one sharing option",
    //       snackPosition: SnackPosition.BOTTOM,
    //       backgroundColor: const Color(0xFFDA605C),
    //       colorText: Colors.white);
    //   return;
    // }
    // Logic to finalize report submission
  }
}

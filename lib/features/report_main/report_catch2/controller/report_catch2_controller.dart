import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';

class ReportCatch2Controller extends GetxController {
  // Pattern Toggle
  var isSamePattern = true.obs;

  // Species Selection
  var selectedSpeciesList = <String>["Tuna", "Snapper", "Dolphin"].obs;

  // Fishing Details (Dynamic Quantities)
  var quantities = <String, int>{"Snapper": 1, "Tuna": 10}.obs;

  // Water Position
  var waterPosition = "Suspended".obs; // Topwater, Suspended, Bottom

  // Form Controllers
  final depthController = TextEditingController(text: "120");
  final strikeZoneController = TextEditingController(text: "80");
  final notesController = TextEditingController();

  var selectedDate = "Select Date".obs;
  var selectedTime = "Select Time".obs;

  void removeSpecies(String name) {
    selectedSpeciesList.remove(name);
  }

  void submitReport() {
    Get.to(OfflineReportsScreen());
    Get.snackbar(
      "Success",
      "Report Submitted Successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}

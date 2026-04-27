import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';

class ReportCatch2Controller extends GetxController {
  // Pattern Toggle
  var isSamePattern = true.obs;

  // Species Selection options
  var speciesOptions = [
    "Tuna",
    "Snapper",
    "Dolphin",
    "Marlin",
    "Grouper",
    "Mackerel",
  ].obs;
  var selectedSpeciesList = <String>["Tuna", "Snapper", "Dolphin"].obs;

  // Fishing Details (Dynamic Quantities)
  var quantities = <String, int>{"Snapper": 1, "Tuna": 10}.obs;

  // Water Position
  var waterPosition = "Suspended".obs; // Topwater, Suspended, Bottom

  // Dropdown Options
  var methodOptions = [
    "Trolling",
    "Bottom Fishing",
    "Jigging",
    "Casting",
    "Fly Fishing",
  ].obs;
  var baitOptions = [
    "Live Bait",
    "Artificial Lure",
    "Cut Bait",
    "Plastic",
    "Metal",
  ].obs;

  // Selected values
  var selectedMethod = "Select Method".obs;
  var selectedBait = "Select bait".obs;

  // Form Controllers
  final depthController = TextEditingController(text: "120");
  final strikeZoneController = TextEditingController(text: "80");
  final notesController = TextEditingController();

  var selectedDate = "Select Date".obs;
  var selectedTime = "Select Time".obs;

  void addSpecies(String name) {
    if (!selectedSpeciesList.contains(name)) {
      selectedSpeciesList.add(name);
    }
  }

  void removeSpecies(String name) {
    selectedSpeciesList.remove(name);
  }

  void updateQuantity(String species, int qty) {
    quantities[species] = qty;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.blue00F0FFColor,
              onPrimary: Colors.white,
              surface: AppColors.blue1B2134Color,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.blue00F0FFColor,
              onPrimary: Colors.white,
              surface: AppColors.blue1B2134Color,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      selectedTime.value = DateFormat('hh:mm a').format(dt);
    }
  }

  void submitReport() {
    Get.to(() => const OfflineReportsScreen());
    Get.snackbar(
      "Success",
      "Report Submitted Successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}

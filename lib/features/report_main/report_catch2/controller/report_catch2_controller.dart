import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';
import 'package:paytonpieper/features/submit_report/screen/submit_report_screen.dart';
import 'package:paytonpieper/core/utils/device/device_utility.dart';

class ReportCatch2Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('MM/dd/yyyy').format(DateTime.now());
    selectedTime.value = DateFormat('hh:mm a').format(DateTime.now());
  }

  // ── Selected location from map picker ─────────────────────────────────────
  var selectedLat = Rxn<double>();
  var selectedLng = Rxn<double>();

  void setSelectedLocation(double lat, double lng) {
    selectedLat.value = lat;
    selectedLng.value = lng;
  }

  // Pattern Toggle
  var isSamePattern = true.obs;

  // Species Selection options
  var speciesOptions = [
    "Tuna",
    "Snapper",
    "Marlin",
    "Grouper",
    "Wahoo",
    "Mahi",
  ].obs;
  var selectedSpeciesList = <String>[].obs;

  // Fishing Details (Dynamic Quantities)
  var quantities = <String, int>{}.obs;

  // Water Position
  var waterPosition = "Suspended".obs; // Topwater, Suspended, Bottom

  // Dropdown Options
  var methodOptions = ["Trolling", "Bottom ", "Jigging", "Live Bailt"].obs;
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

  var selectedDate = DateFormat('MM/dd/yyyy').format(DateTime.now()).obs;
  var selectedTime = DateFormat('hh:mm a').format(DateTime.now()).obs;

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
      lastDate: DateTime.now(),
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

      // Check if picked time is in the future if the selected date is today
      final selectedDateObj = DateFormat(
        'MM/dd/yyyy',
      ).parse(selectedDate.value);
      final today = DateTime(now.year, now.month, now.day);

      if (selectedDateObj.isAtSameMomentAs(today)) {
        if (dt.isAfter(now)) {
          Get.snackbar(
            "Invalid Time",
            "You cannot select a future time for today.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      selectedTime.value = DateFormat('hh:mm a').format(dt);
    }
  }

  Future<void> submitReport() async {
    bool hasInternet = await AppDeviceUtility.hasInternetConnection();
    if (!hasInternet) {
      Get.to(() => const OfflineReportsScreen());
    } else {
      Get.dialog(const VisibilitySharingDialog(), barrierDismissible: true);
    }
  }
}

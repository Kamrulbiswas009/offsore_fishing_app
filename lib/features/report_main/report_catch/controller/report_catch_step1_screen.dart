import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/report_catch2_screen.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

class ReportCatchController extends GetxController {
  // Selection State
  var isGpsSelected = true.obs;
  var detectedGrid = "GOM-2824".obs;
  var currentStep = 1.obs;

  // Manual Selection State
  var selectedManualGrid = "".obs;
  var manualLat = Rxn<double>();
  var manualLng = Rxn<double>();

  void selectGps() => isGpsSelected.value = true;

  /// Opens the map in location-picker mode.
  /// When the user taps a spot, we save the coordinates and resolved zone ID,
  /// then pop back to Step 1 screen so they can confirm.
  void selectManual() {
    isGpsSelected.value = false;
    Get.to(
      () => ZoneMapScreen(
        isLocationPickerMode: true,
        onLocationPicked: (lat, lng) {
          final zoneInfo = ZoneCalculator.fromLatLng(lat, lng);
          if (zoneInfo != null) {
            selectedManualGrid.value = zoneInfo.zoneId;
            manualLat.value = lat;
            manualLng.value = lng;
          } else {
            selectedManualGrid.value = "Selected Point";
            manualLat.value = lat;
            manualLng.value = lng;
          }
          Get.back(); // close map and return to Step 1
        },
      ),
    );
  }

  void confirmGrid() {
    if (isGpsSelected.value) {
      Get.to(const ReportCatch2Screen());
    } else {
      if (manualLat.value != null && manualLng.value != null) {
        Get.to(
          () => ReportCatch2Screen(
            selectedLat: manualLat.value,
            selectedLng: manualLng.value,
          ),
        );
      } else {
        Get.snackbar(
          "Select Location",
          "Please tap on the map to select a grid location first.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/permissions/location_permission_service.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/report_catch2_screen.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

class ReportCatchController extends GetxController {
  // Selection State
  var isGpsSelected = true.obs;
  var detectedGrid = "GOM-R74-C88".obs;
  var currentStep = 1.obs;
  var isRealGps = false.obs;

  // GPS Detected Coordinates
  var gpsLat = Rxn<double>();
  var gpsLng = Rxn<double>();

  // Manual Selection State
  var selectedManualGrid = "".obs;
  var manualLat = Rxn<double>();
  var manualLng = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    initLocationData();
  }

  /// Initializes location data using LocationPermissionService.
  /// If permission granted, uses hardware GPS; if denied/offline, falls back to Gulf of Mexico.
  Future<void> initLocationData() async {
    try {
      final permissionService = Get.find<LocationPermissionService>();
      final locationData = await permissionService
          .getCurrentPositionOrFallback();
      gpsLat.value = locationData.latitude;
      gpsLng.value = locationData.longitude;
      detectedGrid.value = locationData.zoneId;
      isRealGps.value = locationData.isRealGps;
    } catch (_) {
      gpsLat.value = LocationPermissionService.defaultLat;
      gpsLng.value = LocationPermissionService.defaultLng;
      detectedGrid.value = "GOM-R74-C88";
      isRealGps.value = false;
    }
  }

  void selectGps() => isGpsSelected.value = true;

  /// Opens the map in location-picker mode.
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
      Get.to(
        () => ReportCatch2Screen(
          selectedLat: gpsLat.value,
          selectedLng: gpsLng.value,
        ),
      );
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

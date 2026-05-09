import 'package:get/get.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/report_catch2_screen.dart';

class ReportCatchController extends GetxController {
  // Selection State
  var isGpsSelected = true.obs;
  var detectedGrid = "GOM-A12".obs;
  var currentStep = 1.obs;

  void selectGps() => isGpsSelected.value = true;

  /// Opens the map in location-picker mode.
  /// When the user taps a spot, we auto-navigate to ReportCatch2Screen with
  /// the selected lat/lng, skipping the manual "Confirm Grid" button entirely.
  void selectManual() {
    isGpsSelected.value = false;
    Get.to(
      () => ZoneMapScreen(
        isLocationPickerMode: true,
        onLocationPicked: (lat, lng) {
          // Pop the map and push the report-details screen with coordinates
          Get.back(); // close map
          Get.to(
            () => ReportCatch2Screen(
              selectedLat: lat,
              selectedLng: lng,
            ),
          );
        },
      ),
    );
  }

  void confirmGrid() {
    // GPS path: navigate to Step 2 without coordinates (uses device GPS)
    Get.to(const ReportCatch2Screen());
  }
}

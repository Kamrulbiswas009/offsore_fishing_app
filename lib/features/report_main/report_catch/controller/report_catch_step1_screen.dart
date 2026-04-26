import 'package:get/get.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/report_catch2_screen.dart';

class ReportCatchController extends GetxController {
  // Selection State
  var isGpsSelected = true.obs;
  var detectedGrid = "GOM-A12".obs;
  var currentStep = 1.obs;

  void selectGps() => isGpsSelected.value = true;
  void selectManual() => isGpsSelected.value = false;

  void confirmGrid() {
    // Navigate to Step 2: Report Details
    Get.to(ReportCatch2Screen());
  }
}

import 'package:get/get.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';

class ReportSuccessController extends GetxController {
  // Dynamic data passed from the previous screen
  final String species = "Wahoo";
  final String zone = "Zone A-7";
  final String sharingInfo = "1 Group";

  void viewReport() {
    // Logic to navigate to the specific report details
    Get.back();
  }

  void addAnother() {
    // Navigate back to the start of report flow
    Get.offNamed('/reportCatchStep1');
  }

  void close() {
    Get.offAll(() => const MainScreen());
  }
}
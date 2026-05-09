import 'package:get/get.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';


class ReportSuccessController extends GetxController {
  // Dynamic data passed from the previous screen
  final String species = "Wahoo";
  final String zone = "Zone A-7";
  final String sharingInfo = "1 Group";

  void viewReport() {
    // Navigate to the beautiful specific report details screen
    Get.toNamed(
      AppRoute.reportDetailsScreen,
      arguments: {
        "zone": zone,
        "speciesList": [
          {"name": species, "qty": "1"},
        ],
      },
    );
  }

  void addAnother() {
    // Navigate back to the start of report flow
    Get.offNamed('/reportCatchStep1');
  }

  void close() {
    Get.offAll(() => const MainScreen());
  }
}
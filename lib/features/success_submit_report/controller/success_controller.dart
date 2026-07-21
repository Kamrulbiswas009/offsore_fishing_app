import 'package:get/get.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/routes/app_routes.dart';


class ReportSuccessController extends GetxController {
  // Dynamic data passed from the previous screen
  late String species;
  late String zone;
  late String sharingInfo;
  String? reportId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    species = args?['species'] ?? "Wahoo";
    zone = args?['zone'] ?? "Zone A-7";
    sharingInfo = args?['sharingInfo'] ?? "1 Group";
    reportId = args?['reportId'];
  }

  void viewReport() {
    // Navigate to the beautiful specific report details screen
    Get.toNamed(
      AppRoute.reportDetailsScreen,
      arguments: {
        "zone": zone,
        "speciesList": [
          {"name": species, "qty": "1"},
        ],
        "reportId": reportId,
      },
    );
  }

  void addAnother() {
    // Navigate back to the start of report flow
    Get.offNamed('/reportCatchStep1');
  }

  void close() {
    if (Get.currentRoute == AppRoute.succesScreen) {
      Get.back();
    } else {
      Get.offAll(() => MainScreen());
    }
  }
}
import 'package:get/get.dart';
import '../../../core/services/sync_service.dart';

class MainScreenController extends GetxController {
  // Observable index for navigation
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      Get.find<SyncService>().prefetchAppData();
    } catch (e) {
      print("Error triggering prefetch: $e");
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
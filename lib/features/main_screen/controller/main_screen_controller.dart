import 'package:get/get.dart';

class MainScreenController extends GetxController {
  // Observable index for navigation
  var currentIndex = 0.obs;

  // Set of tab indices that have been loaded to prevent eager simultaneous API initialization
  final RxSet<int> loadedIndices = <int>{0}.obs;

  @override
  void onInit() {
    super.onInit();
    loadedIndices.add(currentIndex.value);
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    loadedIndices.add(index);
  }
}
import 'package:get/get.dart';

class MainScreenController extends GetxController {
  // Observable index for navigation
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
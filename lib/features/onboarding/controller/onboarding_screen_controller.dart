import 'package:get/get.dart';

class OnboardingScreenController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void goToStep(int index, GetPageBuilder page) {
    updateIndex(index);
    Get.to(page, transition: Transition.rightToLeft);
  }

  void goBackToStep(int index) {
    updateIndex(index);
    Get.back();
  }
}

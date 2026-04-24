import 'package:get/get.dart';
import 'package:paytonpieper/features/authentication/controllers/create_account_screen_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/forgot_password_screen_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/login_controller.dart';
import 'package:paytonpieper/features/groups/controller/create_group_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';
import 'package:paytonpieper/features/onboarding/controller/onboarding_screen_controller.dart';
import 'package:paytonpieper/features/splash_screen/controller/splash_screen_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(
      () => SplashScreenController(),
      fenix: true,
    );
    Get.lazyPut<OnboardingScreenController>(
      () => OnboardingScreenController(),
      fenix: true,
    );
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<CreateAccountScreenController>(
      () => CreateAccountScreenController(),
      fenix: true,
    );
    Get.lazyPut<ForgotPasswordScreenController>(
      () => ForgotPasswordScreenController(),
      fenix: true,
    );
    Get.lazyPut<GroupMainScreenController>(()=>GroupMainScreenController(),fenix: true);
    Get.lazyPut<CreateGroupScreenController>(()=> CreateGroupScreenController(),fenix: true);
    Get.lazyPut<GroupDetailsScreenController>(()=>GroupDetailsScreenController(), fenix: true);
  }
}

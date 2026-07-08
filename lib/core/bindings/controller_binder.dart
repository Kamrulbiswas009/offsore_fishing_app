import 'package:get/get.dart';
import 'package:paytonpieper/core/services/permissions/location_permission_service.dart';
import 'package:paytonpieper/features/authentication/controllers/apple_login_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/google_login_controller.dart';
import 'package:paytonpieper/features/groups/controller/message_service_controller.dart';
import 'package:paytonpieper/features/groups/controller/see_my_invitation_controller.dart';
import 'package:paytonpieper/features/main_screen/controller/filter_controller.dart';
import 'package:paytonpieper/features/main_screen/controller/main_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/create_group_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/group_details_screen_controller.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';
import 'package:paytonpieper/features/map/controller/map_screen_controller.dart';
import 'package:paytonpieper/features/notification/controller/notification_screen_controller.dart';
import 'package:paytonpieper/features/onboarding/controller/onboarding_screen_controller.dart';
import 'package:paytonpieper/features/payment_service/controller/payment_service_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/profile_main_screen_controller.dart';
import 'package:paytonpieper/features/profile_and_setting/controller/settings_screen_controller.dart';
import 'package:paytonpieper/features/report_main/offline_report/controller/offline_report_controller.dart';
import 'package:paytonpieper/features/report_main/report_catch/controller/report_catch_step1_screen.dart';
import 'package:paytonpieper/features/report_main/report_catch2/controller/report_catch2_controller.dart';
import 'package:paytonpieper/features/report_main/summary/controller/summary_details_controller.dart';
import 'package:paytonpieper/features/splash_screen/controller/splash_screen_controller.dart';
import 'package:paytonpieper/core/services/sync_service.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.put(SyncService(), permanent: true);
    Get.lazyPut<LocationPermissionService>(
      () => LocationPermissionService(),
      fenix: true,
    );
    Get.lazyPut<SplashScreenController>(
      () => SplashScreenController(),
      fenix: true,
    );
    Get.lazyPut<OnboardingScreenController>(
      () => OnboardingScreenController(),
      fenix: true,
    );
    Get.lazyPut<GroupMainScreenController>(
      () => GroupMainScreenController(),
      fenix: true,
    );
    Get.lazyPut<CreateGroupScreenController>(
      () => CreateGroupScreenController(),
      fenix: true,
    );
    Get.lazyPut<GroupDetailsScreenController>(
      () => GroupDetailsScreenController(),
      fenix: true,
    );
    Get.lazyPut<ProfileMainScreenController>(
      () => ProfileMainScreenController(),
      fenix: true,
    );
    Get.lazyPut<SettingsScreenController>(
      () => SettingsScreenController(),
      fenix: true,
    );
    Get.lazyPut<NotificationScreenController>(
      () => NotificationScreenController(),
      fenix: true,
    );
    Get.lazyPut<MapScreenController>(() => MapScreenController(), fenix: true);
    Get.put(MainScreenController(), permanent: true);
    Get.lazyPut<FilterController>(() => FilterController(), fenix: true);
    Get.lazyPut<SummaryController>(() => SummaryController(), fenix: true);
    Get.lazyPut<ReportCatchController>(
      () => ReportCatchController(),
      fenix: true,
    );
    Get.lazyPut<ReportCatch2Controller>(
      () => ReportCatch2Controller(),
      fenix: true,
    );
    Get.lazyPut<OfflineReportsTabController>(
      () => OfflineReportsTabController(),
      fenix: true,
    );
    Get.lazyPut<SeeMyInvitationController>(
      () => SeeMyInvitationController(),
      fenix: true,
    );
    Get.lazyPut<GoogleLoginController>(
      () => GoogleLoginController(),
      fenix: true,
    );
    Get.lazyPut<AppleLoginController>(
      () => AppleLoginController(),
      fenix: true,
    );
    Get.lazyPut<MessageServiceController>(
      () => MessageServiceController(),
      fenix: true,
    );
    Get.lazyPut<PaymentServiceController>(
      () => PaymentServiceController(),
      fenix: true,
    );
  }
}

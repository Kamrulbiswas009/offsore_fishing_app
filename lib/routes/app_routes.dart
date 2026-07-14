import 'package:get/get.dart';
import 'package:paytonpieper/features/authentication/controllers/create_account_screen_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/forgot_password_screen_controller.dart';
import 'package:paytonpieper/features/authentication/controllers/login_controller.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/create_account_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/login_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/set_new_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/verify_email_otp_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/verify_otp_screen.dart';
import 'package:paytonpieper/features/groups/presentation/screen/create_group_screen.dart';
import 'package:paytonpieper/features/groups/presentation/screen/group_details_screen.dart';
import 'package:paytonpieper/features/map/screen/zone_map_screen.dart';
import 'package:paytonpieper/features/notification/presentation/screen/notification_screen.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboardin_screen3.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen1.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen2.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen4.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/settings_screen.dart';
import 'package:paytonpieper/features/splash_screen/presentation/screen/splash_screen1.dart';
import 'package:paytonpieper/features/report_main/summary/screen/summary_details.dart';
import 'package:paytonpieper/features/report_main/summary/controller/summary_details_controller.dart';
import 'package:paytonpieper/features/success_submit_report/screen/report_details_screen.dart';
import 'package:paytonpieper/features/success_submit_report/controller/report_details_controller.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/profile_main_screen.dart';
import 'package:paytonpieper/features/groups/presentation/screen/group_main_screen.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/features/report_main/report_catch2/screen/report_catch2_screen.dart';
import 'package:paytonpieper/features/submit_report/screen/submit_report_screen.dart';
import 'package:paytonpieper/features/report_main/offline_report/screen/offline_report_screen.dart';
import 'package:paytonpieper/features/success_submit_report/screen/succes_screen.dart';

class AppRoute {
  static String splashScreen1 = "/splashScreen1";
  static String onboardingScreen1 = "/onboardingScreen1";
  static String onboardingScreen2 = "/onboardingScreen2";
  static String onboardingScreen3 = "/onboardingScreen3";
  static String onboardingScreen4 = "/onboardingScreen4";
  static String loginScreen = "/loginScreen";
  static String createAccountScreen = "/createAccountScreen";
  static String forgotPasswordScreen = "/forgotPasswordScreen";
  static String veriryOtpScreen = "/veriryOtpScreen";
  static String setNewPasswordScreen = "/setNewPasswordScreen";
  static String createGroupScreen = "/createGroupScreen";
  static String groupDetailsScreen = "/groupDetailsScreen";
  static String settingsScreen = "/settingsScreen";
  static String notificationScreen = "/notificationScreen";
  static String zoneMapScreen = "/zone_map_screen";
  static String summaryScreen = "/summary-details";
  static String reportDetailsScreen = "/report-details";
  static String homeMainScreen = "/homeMainScreen";
  static String profileMainScreen = "/profileMainScreen";
  static String groupMainScreen = "/groupMainScreen";
  static String reportCatchScreen = "/reportCatchScreen";
  static String reportCatch2Screen = "/reportCatch2Screen";
  static String submitReportScreen = "/submitReportScreen";
  static String offlineReportScreen = "/offlineReportScreen";
  static String succesScreen = "/succesScreen";
  static String verifyEmailOtpScreen = "/VerifyEmailOtpScreen";

  static String getSplashScreen1() => splashScreen1;
  static String getOnboardingScreen1() => onboardingScreen1;
  static String getOnboardingScreen2() => onboardingScreen2;
  static String getOnboardingScreen3() => onboardingScreen3;
  static String getOnboardingScreen4() => onboardingScreen4;
  static String getLoginScreen() => loginScreen;
  static String getCreateAccountScreen() => createAccountScreen;
  static String getForgotPasswordScreen() => forgotPasswordScreen;
  static String getVeriryOtpScreen() => veriryOtpScreen;
  static String getSetNewPasswordScreen() => setNewPasswordScreen;
  static String getCreateGroupScreen() => createGroupScreen;
  static String getGroupDetailsScreen() => groupDetailsScreen;
  static String getSettingsScreen() => settingsScreen;
  static String getNotificationScreen() => notificationScreen;
  static String getZoneMapScreen() => zoneMapScreen;
  static String getSummaryScreen() => summaryScreen;
  static String getReportDetailsScreen() => reportDetailsScreen;
  static String getHomeMainScreen() => homeMainScreen;
  static String getProfileMainScreen() => profileMainScreen;
  static String getGroupMainScreen() => groupMainScreen;
  static String getReportCatchScreen() => reportCatchScreen;
  static String getReportCatch2Screen() => reportCatch2Screen;
  static String getSubmitReportScreen() => submitReportScreen;
  static String getOfflineReportScreen() => offlineReportScreen;
  static String getSuccesScreen() => succesScreen;
  static String getVerifyEmailOtpScreen()=> verifyEmailOtpScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen1, page: () => SplashScreen1()),
    GetPage(name: onboardingScreen1, page: () => OnboardingScreen1()),
    GetPage(name: onboardingScreen2, page: () => OnboardingScreen2()),
    GetPage(name: onboardingScreen3, page: () => OnboardingScreen3()),
    GetPage(name: onboardingScreen4, page: () => OnboardingScreen4()),
    GetPage(
      name: loginScreen,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(LoginController());
      }),
    ),
    GetPage(
      name: createAccountScreen,
      page: () => CreateAccountScreen(),
      binding: BindingsBuilder(() {
        Get.put(CreateAccountScreenController());
      }),
    ),
    GetPage(
      name: forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.put(ForgotPasswordScreenController());
      }),
    ),
    GetPage(name: veriryOtpScreen, page: () => VerifyOtpScreen()),
    GetPage(name: setNewPasswordScreen, page: () => SetNewPasswordScreen()),
    GetPage(
      name: createGroupScreen,
      page: () => CreateGroupScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: groupDetailsScreen,
      page: () => GroupDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settingsScreen,
      page: () => SettingsScreen(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: notificationScreen,
      page: () => NotificationScreen(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: zoneMapScreen,
      page: () => const ZoneMapScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: summaryScreen,
      page: () => SummaryScreen(isReportMainScreen: Get.arguments as bool),
      binding: BindingsBuilder(() {
        Get.put(SummaryController());
      }),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: reportDetailsScreen,
      page: () => const ReportDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.put(ReportDetailsController());
      }),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: homeMainScreen,
      page: () =>  MainScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: profileMainScreen,
      page: () => ProfileMainScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: groupMainScreen,
      page: () => GroupMainScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: reportCatchScreen,
      page: () => ReportCatchStep1Screen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: reportCatch2Screen,
      page: () => ReportCatch2Screen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: submitReportScreen,
      page: () => const VisibilitySharingDialog(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: offlineReportScreen,
      page: () => const OfflineReportsScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: succesScreen,
      page: () => const ReportSuccessScreen(),
      transition: Transition.leftToRight,
    ),

    GetPage(
      name: verifyEmailOtpScreen, 
      page: ()=> VerifyEmailOtpScreen()),
  ];
}

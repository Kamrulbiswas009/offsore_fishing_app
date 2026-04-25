import 'package:get/get.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/create_account_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/login_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/set_new_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/veriry_otp_screen.dart';
import 'package:paytonpieper/features/groups/presentation/screen/create_group_screen.dart';
import 'package:paytonpieper/features/groups/presentation/screen/group_details_screen.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboardin_screen3.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen1.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen2.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen4.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/settings_screen.dart';
import 'package:paytonpieper/features/splash_screen/presentation/screen/splash_screen1.dart';

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

  static List<GetPage> routes = [
    GetPage(name: splashScreen1, page: () => SplashScreen1()),
    GetPage(name: onboardingScreen1, page: () => OnboardingScreen1()),
    GetPage(name: onboardingScreen2, page: () => OnboardingScreen2()),
    GetPage(name: onboardingScreen3, page: () => OnboardingScreen3()),
    GetPage(name: onboardingScreen4, page: () => OnboardingScreen4()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: createAccountScreen, page: () => CreateAccountScreen()),
    GetPage(name: forgotPasswordScreen, page: () => ForgotPasswordScreen()),
    GetPage(name: veriryOtpScreen, page: () => VeriryOtpScreen()),
    GetPage(name: setNewPasswordScreen, page: () => SetNewPasswordScreen()),
    GetPage(
      name: createGroupScreen,
      page: () => CreateGroupScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: groupDetailsScreen,
      page: () => GroupDetailsScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: settingsScreen,
      page: () => SettingsScreen(),
      transition: Transition.leftToRight,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}

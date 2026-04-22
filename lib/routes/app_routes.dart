import 'package:get/get.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/create_account_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:paytonpieper/features/authentication/presentation/screens/login_screen.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboardin_screen3.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen1.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen2.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen4.dart';
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

  static String getSplashScreen1() => splashScreen1;
  static String getOnboardingScreen1() => onboardingScreen1;
  static String getOnboardingScreen2() => onboardingScreen2;
  static String getOnboardingScreen3() => onboardingScreen3;
  static String getOnboardingScreen4() => onboardingScreen4;
  static String getLoginScreen() => loginScreen;
  static String getCreateAccountScreen() => createAccountScreen;
  static String getForgotPasswordScreen() => forgotPasswordScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen1, page: () => SplashScreen1()),
    GetPage(name: onboardingScreen1, page: () => OnboardingScreen1()),
    GetPage(name: onboardingScreen2, page: () => OnboardingScreen2()),
    GetPage(name: onboardingScreen3, page: () => OnboardingScreen3()),
    GetPage(name: onboardingScreen4, page: () => OnboardingScreen4()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: createAccountScreen, page: () => CreateAccountScreen()),
    GetPage(name: forgotPasswordScreen, page: () => ForgotPasswordScreen()),
  ];
}

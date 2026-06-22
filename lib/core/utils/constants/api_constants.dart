class ApiConstants {
  //static const String baseUrl =
     // "https://coefficiently-vermiform-tatiana.ngrok-free.dev/api/v1";
  static const String baseUrl = "http://172.252.13.68:8000/api/v1";

  //Authentication Flow ->
  static const String createAccountApi = "$baseUrl/auth/signup";
  static const String verifyEmailApi = "$baseUrl/auth/verify-email";

  static const String loginApi = "$baseUrl/auth/login";

  static const String authMeApi = "$baseUrl/user/me";
  static const String getAccessTokenApi = "$baseUrl/auth/refresh-token";

  static const String forgotEmailSendApi = "$baseUrl/auth/forget-password";
  static const String verifyForgotPasswordWithOtpApi = "$baseUrl/auth/reset-password";
}

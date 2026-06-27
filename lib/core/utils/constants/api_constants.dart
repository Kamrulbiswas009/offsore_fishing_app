class ApiConstants {
  //static const String baseUrl =
  // "https://coefficiently-vermiform-tatiana.ngrok-free.dev/api/v1";
  static const String baseUrl = "http://172.252.13.68:8000/api/v1";

  //Authentication Flow ->
  static const String createAccountApi = "$baseUrl/auth/signup";
  static const String verifyEmailApi = "$baseUrl/auth/verify-email";

  static const String loginApi = "$baseUrl/auth/login";

  static const String authMeApi = "$baseUrl/user/me";
  static const String updateProfileApi = "$baseUrl/user/profile-update";
  static const String getAccessTokenApi = "$baseUrl/auth/refresh-token";

  static const String forgotEmailSendApi = "$baseUrl/auth/forget-password";
  static const String verifyForgotPasswordWithOtpApi =
      "$baseUrl/auth/reset-password";

  //Group Flow ->
  static const String featchGroupListApi = "$baseUrl/groups";
  static String featchSingleGroupDetailsApi(String groupId) =>
      "$baseUrl/groups/$groupId";
  static String createNewGroupApi = "$baseUrl/groups";
  static String updateGroupApi(String groupId) => "$baseUrl/groups/$groupId";
  static String deleteGroupApi(String groupId) => "$baseUrl/groups/$groupId";

  //Group Invitation Flow ->
  static String generateGroupInvitationCodeApi(String groupId) =>
      "$baseUrl/invites/groups/$groupId";
  static const String joinGroupWithCodeApi = "$baseUrl/invites/join";
  static String leaveGroupApi(String groupId) =>
      "$baseUrl/groups/$groupId/leave";

  static String featchUserForInviationApi(
    String search,
    int page,
    int limit,
    String groupId,
  ) =>
      "$baseUrl/user/all-user?search=$search&page=$page&limit=$limit&groupId=$groupId";

  static const String seeMyInvitationApi = "$baseUrl/invites/my-pending";
  static String approveInvitationApi(String inviteId) => "$baseUrl/invites/$inviteId/accept";
  static String rejectInvitationApi(String inviteId) => "$baseUrl/invites/$inviteId/decline";
}

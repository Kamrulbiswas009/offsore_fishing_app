class ApiConstants {
  //static const String baseUrl =
  // "https://coefficiently-vermiform-tatiana.ngrok-free.dev/api/v1";
  static const String baseUrl = "http://172.252.13.68:8000/api/v1";
  static const String stormGlassApiKey = "cb2f317e-409f-11f1-beac-0242ac120004-cb2f31e2-409f-11f1-beac-0242ac120004";
  static String get socketBaseUrl =>
      baseUrl.replaceFirst(RegExp(r'/api/v\d+/?$'), '');

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
  static String approveInvitationApi(String inviteId) =>
      "$baseUrl/invites/$inviteId/accept";
  static String rejectInvitationApi(String inviteId) =>
      "$baseUrl/invites/$inviteId/decline";
  static String showAllPendingInvitationOfAGroupApi(String groupId) =>
      "$baseUrl/invites/groups/$groupId";
  static String revokeInvitationUserApi(String inviteId) =>
      "$baseUrl/invites/$inviteId/revoke";
  static String removeMemberFromGroupByOwnerApi(
    String groupId,
    String userId,
  ) => "$baseUrl/groups/$groupId/members/$userId";

  //Reports Flow ->
  static const String submitReportApi = "$baseUrl/reports";
  static String getSingleReportDetailsApi(String reportId) => "$baseUrl/reports/$reportId";
  static const String getRegionReportsApi =
      "$baseUrl/zones/reports?regionCode=GOM&scope=region";
  static const String getZoneSummaryApi = "$baseUrl/zones/summary";
  
  static String getFilteredZoneSummaryApi({
    String? zoneId,
    String? zoneIds,
    String regionCode = "GOM",
    double? lat,
    double? lng,
    String? scope,
    String? species,
    int? depthMinFt,
    int? depthMaxFt,
    String? fishingMethod,
    String? visibility,
    String? timeRange,
    int page = 1,
    int limit = 20,
  }) {
    final queryParameters = <String, String>{
      'regionCode': regionCode,
      if (zoneId != null && zoneId.isNotEmpty) 'zoneId': zoneId,
      if (zoneIds != null && zoneIds.isNotEmpty) 'zoneIds': zoneIds,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (scope != null && scope.isNotEmpty) 'scope': scope,
      if (species != null && species.isNotEmpty) 'species': species,
      if (depthMinFt != null) 'depthMinFt': depthMinFt.toString(),
      if (depthMaxFt != null) 'depthMaxFt': depthMaxFt.toString(),
      if (fishingMethod != null && fishingMethod.isNotEmpty)
        'fishingMethod': fishingMethod,
      if (visibility != null && visibility.isNotEmpty)
        'visibility': visibility,
      if (timeRange != null && timeRange.isNotEmpty)
        'timeRange': timeRange,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return Uri.parse(getZoneSummaryApi)
        .replace(queryParameters: queryParameters)
        .toString();
  }
  
 static String confirmReportApi(String reportId) => "$baseUrl/reports/$reportId/confirm";
  static String rejectReportApi(String reportId) => "$baseUrl/reports/$reportId/reject";
  static String getZonesApi({
    required double south,
    required double north,
    required double west,
    required double east,
    String? species,
    int? depthMinFt,
    int? depthMaxFt,
    String? fishingMethod,
    String? visibility,
    String? timeRange,
  }) {
    final queryParameters = <String, String>{
      'south': south.toString(),
      'north': north.toString(),
      'west': west.toString(),
      'east': east.toString(),
      if (species != null && species.isNotEmpty) 'species': species,
      if (depthMinFt != null) 'depthMinFt': depthMinFt.toString(),
      if (depthMaxFt != null) 'depthMaxFt': depthMaxFt.toString(),
      if (fishingMethod != null && fishingMethod.isNotEmpty)
        'fishingMethod': fishingMethod,
      if (visibility != null && visibility.isNotEmpty)
        'visibility': visibility,
      if (timeRange != null && timeRange.isNotEmpty)
        'timeRange': timeRange,
    };

    return Uri.parse("$baseUrl/zones")
        .replace(queryParameters: queryParameters)
        .toString();
  }

  static String getFilteredRegionReportsApi({
    String regionCode = "GOM",
    String scope = "region",
    String? species,
    String? timeframe,
    String? fishingMethod,
    int? depthMinFt,
    int? depthMaxFt,
    String? visibility,
  }) {
    final queryParameters = <String, String>{
      'regionCode': regionCode,
      'scope': scope,
      if (species != null && species.isNotEmpty) 'species': species,
      if (timeframe != null && timeframe.isNotEmpty) 'timeframe': timeframe,
      if (fishingMethod != null && fishingMethod.isNotEmpty)
        'fishingMethod': fishingMethod,
      if (depthMinFt != null) 'depthMinFt': depthMinFt.toString(),
      if (depthMaxFt != null) 'depthMaxFt': depthMaxFt.toString(),
      if (visibility != null && visibility.isNotEmpty)
        'visibility': visibility,
    };

    return Uri.parse("$baseUrl/zones/reports")
        .replace(queryParameters: queryParameters)
        .toString();
  }
//}


  //payment flow-
  static String getPaymentPlanApi = "$baseUrl/subscriptions/plans";
  static const String createPaymentIntentPlanApi = "$baseUrl/subscriptions/intent";

  //report-get-for-group
  static String getReportForGroupApi({
    required String groupId,
    String? species,
    String? timeframe,
    String? fishingMethod,
    int? depthMinFt,
    int? depthMaxFt,
    int page = 1,
    int limit = 20,
  }) {
    final queryParameters = <String, String>{
      'groupId': groupId,
      if (species != null && species.isNotEmpty) 'species': species,
      if (timeframe != null && timeframe.isNotEmpty) 'timeframe': timeframe,
      if (fishingMethod != null && fishingMethod.isNotEmpty)
        'fishingMethod': fishingMethod,
      if (depthMinFt != null) 'depthMinFt': depthMinFt.toString(),
      if (depthMaxFt != null) 'depthMaxFt': depthMaxFt.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return Uri.parse(
      "$baseUrl/reports",
    ).replace(queryParameters: queryParameters).toString();
  }


  //profile stat card -->
  static const String featchProfileStatApi = "$baseUrl/user/stats";
  static const String deleteAccountApi = "$baseUrl/user/delete";
}

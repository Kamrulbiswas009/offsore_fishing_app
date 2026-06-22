import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paytonpieper/core/models/response_data.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/profile_and_setting/model/auth_me_model.dart';
import 'package:paytonpieper/routes/app_routes.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/utils/constants/colors.dart';
import 'package:paytonpieper/core/utils/constants/icon_path.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/features/notification/presentation/screen/notification_screen.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/screen/settings_screen.dart';
import 'package:paytonpieper/features/profile_and_setting/presentation/widget/profile_main_screen_widget/edit_profile_dialog.dart';

class ProfileMainScreenController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();
  final Rxn<AuthMeModel> authMe = Rxn<AuthMeModel>();

  // --- Edit Profile State ---
  final Rxn<File> selectedImageFile = Rxn<File>();
  final TextEditingController editNameController = TextEditingController();

  String get profileName => authMe.value?.name ?? 'Captain Mike';
  String get email => authMe.value?.email ?? 'captain.mike@example.com';
  String get profileImagePath =>
      authMe.value?.profileImage ?? ImagePath.messageProfileImage;

  @override
  void onInit() {
    super.onInit();
    getAuthMe();
  }

  @override
  void onClose() {
    editNameController.dispose();
    super.onClose();
  }

  Future<void> getAuthMe() async {
    await EasyLoading.show(status: 'Loading profile...');
    AppLoggerHelper.info('Fetching user profile.');

    try {
      var response = await _requestAuthMe();

      if (!response.isSuccess) {
        AppLoggerHelper.warning(
          'Profile request failed (${response.statusCode}). '
          'Attempting to refresh the access token.',
        );

        final didRefresh = await _refreshAccessToken();
        if (!didRefresh) {
          AppLoggerHelper.error(
            'Profile fetch failed because the access token could not be refreshed.',
          );
          return;
        }

        AppLoggerHelper.info(
          'Access token refreshed. Retrying profile request.',
        );
        response = await _requestAuthMe();
      }

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Profile fetch failed after retry: ${response.errorMessage}',
        );
        return;
      }

      final responseBody = response.responseData;
      final data = responseBody is Map ? responseBody['data'] : null;
      if (data is! Map) {
        AppLoggerHelper.error(
          'Profile response did not contain valid user data.',
        );
        return;
      }

      final profile = AuthMeModel.fromJson(Map<String, dynamic>.from(data));
      authMe.value = profile;
      if (profile.userId.isNotEmpty) {
        await StorageService.saveUserId(profile.userId);
      }
      AppLoggerHelper.info('User profile fetched successfully.');
    } catch (error) {
      AppLoggerHelper.error('Profile fetch failed unexpectedly.', error);
    } finally {
      await EasyLoading.dismiss();
    }
  }

  Future<ResponseData> _requestAuthMe() {
    final accessToken = StorageService.token;
    return _networkCaller.getRequest(
      ApiConstants.authMeApi,
      token: accessToken == null || accessToken.isEmpty
          ? null
          : 'Bearer $accessToken',
    );
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = StorageService.refreshToken;
    final userId = StorageService.userId ?? _userIdFromToken(refreshToken);

    if (refreshToken == null || refreshToken.isEmpty || userId == null) {
      AppLoggerHelper.error(
        'Token refresh skipped because userId or refreshToken is missing.',
      );
      return false;
    }

    final response = await _networkCaller.postRequest(
      ApiConstants.getAccessTokenApi,
      body: {'userId': userId, 'refreshToken': refreshToken},
    );

    if (!response.isSuccess) {
      AppLoggerHelper.error('Token refresh failed: ${response.errorMessage}');
      return false;
    }

    final responseBody = response.responseData;
    final data = responseBody is Map ? responseBody['data'] : null;
    final newAccessToken = data is Map ? data['accessToken'] : null;
    final newRefreshToken = data is Map ? data['refreshToken'] : null;

    if (newAccessToken is! String ||
        newAccessToken.isEmpty ||
        newRefreshToken is! String ||
        newRefreshToken.isEmpty) {
      AppLoggerHelper.error('Token refresh response contained invalid tokens.');
      return false;
    }

    await StorageService.saveAuthTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
    await StorageService.saveUserId(userId);
    return true;
  }

  String? _userIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final subject = payload is Map ? payload['sub'] : null;
      return subject is String && subject.isNotEmpty ? subject : null;
    } catch (error) {
      AppLoggerHelper.error('Could not read userId from refresh token.', error);
      return null;
    }
  }

  late final List<ProfileStatModel> stats = <ProfileStatModel>[
    ProfileStatModel(
      value: '127',
      label: 'Reports Submitted',
      iconPath: IconPath.fishIcon,
      borderColor: AppColors.tealColor117A88.withValues(alpha: 0.15),
      iconBackgroundColor: AppColors.teal163A42Color,
    ),
    ProfileStatModel(
      value: '18',
      label: 'confirmed reports',
      iconPath: IconPath.locationIcon,
      borderColor: AppColors.orangeFF6B35Color.withValues(alpha: 0.30),
      iconBackgroundColor: AppColors.orange3F2B27Color,
    ),
    ProfileStatModel(
      value: '42',
      label: 'Pattern Matches',
      iconPath: IconPath.curveArrowIcon,
      borderColor: AppColors.tealColor117A88,
      iconBackgroundColor: AppColors.green10B981Color.withValues(alpha: 0.15),
    ),
  ];

  late final SubscriptionPlanModel subscriptionPlan =
      const SubscriptionPlanModel(
        title: 'Free Plan',
        price: '\$0',
        description: 'Basic features with delayed data',
        features: <String>[
          'Delayed heatmap (6-24h)',
          'Limited report access',
          'Basic notifications',
          'Standard analytics',
        ],
      );

  void onNotificationsTap() {
    Get.to(() => NotificationScreen());
  }

  void onEditProfile() {
    // Pre-fill name with current profile name
    editNameController.text = profileName;
    // Reset any previously selected image
    selectedImageFile.value = null;

    Get.dialog(
      EditProfileDialog(controller: this),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        selectedImageFile.value = File(pickedFile.path);
        AppLoggerHelper.info('Profile image selected: ${pickedFile.path}');
      }
    } catch (error) {
      AppLoggerHelper.error('Failed to pick image from gallery.', error);
    }
  }

  Future<void> updateProfile() async {
    final name = editNameController.text.trim();
    final imageFile = selectedImageFile.value;

    if (name.isEmpty) {
      AppLoggerHelper.warning('Profile update skipped: name is empty.');
      return;
    }

    AppLoggerHelper.info('Updating profile with name: "$name"');
    await EasyLoading.show(status: 'Updating profile...');

    try {
      final accessToken = StorageService.token;
      final token =
          (accessToken != null && accessToken.isNotEmpty)
              ? 'Bearer $accessToken'
              : null;

      final response = await _networkCaller.patchMultipartRequest(
        ApiConstants.updateProfileApi,
        fields: {'userName': name},
        file: imageFile,
        fileFieldName: 'file',
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info('Profile updated successfully.');
        Get.back(); // close dialog
        await getAuthMe(); // re-fetch profile
      } else {
        AppLoggerHelper.error(
          'Profile update failed: ${response.errorMessage}',
        );
      }
    } catch (error) {
      AppLoggerHelper.error('Profile update threw an unexpected error.', error);
    } finally {
      await EasyLoading.dismiss();
    }
  }

  void onUpgradeToPro() {
    CommonMessage.showMessage(
      title: "Alert",
      message: "This is under developement",
    );
  }

  Future<void> onLogout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.containerBackgroundColor,
        title: const Text(
          'Confirm logout',
          style: TextStyle(color: AppColors.whiteColor),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.greyC8D0DBColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.greyC8D0DBColor),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppColors.redDA605CColor),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (shouldLogout != true) return;

    await EasyLoading.show(status: 'Logging out...');

    try {
      await StorageService.logoutUser();
      authMe.value = null;
      AppLoggerHelper.info('Logout successful. Local data cleared.');
    } catch (error) {
      AppLoggerHelper.error('Logout failed while clearing local data.', error);
      CommonMessage.showMessage(
        title: 'Logout failed',
        message: 'Could not clear your local data. Please try again.',
      );
      return;
    } finally {
      await EasyLoading.dismiss();
    }

    Get.offAllNamed(AppRoute.getLoginScreen());
  }

  void openSettings() {
    Get.to(() => SettingsScreen());
  }
}

class ProfileStatModel {
  final String value;
  final String label;
  final String iconPath;
  final Color borderColor;
  final Color iconBackgroundColor;

  const ProfileStatModel({
    required this.value,
    required this.label,
    required this.iconPath,
    required this.borderColor,
    required this.iconBackgroundColor,
  });
}

class SubscriptionPlanModel {
  final String title;
  final String price;
  final String description;
  final List<String> features;

  const SubscriptionPlanModel({
    required this.title,
    required this.price,
    required this.description,
    required this.features,
  });
}

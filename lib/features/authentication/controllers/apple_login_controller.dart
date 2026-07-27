import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';

/// GetX Controller for handling Apple Sign-In flow with Firebase Authentication.
///
/// Handles raw nonce generation, SHA-256 hashing, Apple ID credential request,
/// Firebase credential creation, reactive loading states (`RxBool`), and error handling
/// (including user cancellation).
class AppleLoginController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Reactive loading state for Apple Sign-In process.
  final RxBool isLoading = false.obs;

  /// Executes the Apple Sign-In flow using Firebase Authentication.
  Future<void> continueWithApple() async {
    print(await SignInWithApple.isAvailable());
    isLoading.value = true;
    await EasyLoading.show(status: 'Signing in with Apple...');

    try {
      // 1. Check if Apple Sign-In is supported on the current device
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        AppLoggerHelper.error('Apple Sign-In is not supported on this device.');
        CommonMessage.showMessage(
          title: 'Apple Sign-In Failed',
          message: 'Apple Sign-In is not supported on this device.',
          backgroundColor: Colors.red,
        );
        return;
      }

      // 2. Generate cryptographically secure raw nonce and compute its SHA-256 hash
      final rawNonce = _generateCryptoRandomNonce();
      final sha256Nonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // 3. Prompt user for Apple ID authorization credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256Nonce,
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        AppLoggerHelper.error('Apple Sign-In failed: No identity token returned.');
        CommonMessage.showMessage(
          title: 'Apple Sign-In Failed',
          message: 'Apple authentication did not return a valid token.',
          backgroundColor: Colors.red,
        );
        return;
      }

      AppLoggerHelper.info(
        'Apple Sign-In success: '
        'email=${appleCredential.email}, '
        'givenName=${appleCredential.givenName}, '
        'familyName=${appleCredential.familyName}',
      );

      // 4. Generate Firebase OAuthCredential for apple.com provider
      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      // 5. Authenticate with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      AppLoggerHelper.info(
        'Firebase Apple Auth success: uid=${user?.uid}, email=${user?.email}',
      );

      // Print credentials on successful Apple login
      final userId = user?.uid ?? appleCredential.userIdentifier;
      print('id: $userId');
      print('token: $idToken');
      print('provider: apple');

      AppLoggerHelper.info('id: $userId');
      AppLoggerHelper.info('token: $idToken');
      AppLoggerHelper.info('provider: apple');

      // Fetch FCM token if available
      String? fcmToken;
      try {
        if (Platform.isIOS) {
          final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) {
            fcmToken = await FirebaseMessaging.instance.getToken();
          }
        } else {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await StorageService.saveFcmToken(fcmToken);
        }
      } catch (_) {
        fcmToken = StorageService.fcmToken;
      }

      // Extract user full name
      String name = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((s) => s != null && s.trim().isNotEmpty).join(' ');

      if (name.isEmpty) {
        name = user?.displayName ?? '';
      }

      // 6. Call backend socialLogin API matching schema:
      // { "idToken": "...", "provider": "APPLE", "fcmToken": "...", "name": "..." }
      final Map<String, dynamic> requestBody = {
        'idToken': idToken,
        'provider': 'APPLE',
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        if (name.isNotEmpty) 'name': name,
      };

      AppLoggerHelper.info('Social login request body: $requestBody');

      final response = await _networkCaller.postRequest(
        ApiConstants.socialLoginApi,
        body: requestBody,
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error('Social Login failed: ${response.errorMessage}');
        CommonMessage.showMessage(
          title: 'Apple Sign-In Failed',
          message: response.errorMessage,
          backgroundColor: Colors.red,
        );
        return;
      }

      final responseBody = response.responseData;
      AppLoggerHelper.info('Social login response: $responseBody');

      final data = responseBody is Map ? responseBody['data'] : null;
      final accessToken = data is Map ? data['accessToken'] : null;
      final refreshToken = data is Map ? data['refreshToken'] : null;

      // 7. Only proceed (save tokens + navigate) if a valid accessToken was returned.
      if (accessToken is String && accessToken.isNotEmpty) {
        await StorageService.saveAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken is String ? refreshToken : '',
        );
        if (userId != null && userId.isNotEmpty) {
          await StorageService.saveUserId(userId);
        }
        AppLoggerHelper.info('Social login successful and auth tokens saved.');

        try {
          final biteCtrl = Get.find<BiteWatchController>();
          await biteCtrl.uploadFcmToken();
          await biteCtrl.fetchWatchedZones();
        } catch (e) {
          AppLoggerHelper.error('Failed to sync FCM / watched zones on Apple login', e);
        }

        // ✅ Navigate ONLY after tokens are confirmed saved
        Get.offAll(() => MainScreen());
      } else {
        // ⛔ Backend responded success but no usable accessToken — don't navigate.
        AppLoggerHelper.error(
          'Social Login response missing accessToken. Full response: $responseBody',
        );
        CommonMessage.showMessage(
          title: 'Apple Sign-In Failed',
          message:
              'Login succeeded but session could not be established. Please try again.',
          backgroundColor: Colors.red,
        );
      }
    } on SignInWithAppleAuthorizationException catch (error) {
      debugPrint("Code : ${error.code}");
      debugPrint("Message : ${error.message}");
      debugPrint("Exception : $error");
      rethrow;
    } on FirebaseAuthException catch (error) {
      AppLoggerHelper.error(
        'Firebase Apple Auth failed: ${error.code} - ${error.message}',
        error,
      );
      CommonMessage.showMessage(
        title: 'Apple Sign-In Failed',
        message: error.message ?? 'Unable to authenticate with Firebase.',
        backgroundColor: Colors.red,
      );
    } catch (error) {
      AppLoggerHelper.error('Apple Sign-In failed unexpectedly', error);
      CommonMessage.showMessage(
        title: 'Apple Sign-In Failed',
        message: 'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
      await EasyLoading.dismiss();
    }
  }

  /// Generates a cryptographically secure random string to use as a raw nonce.
  String _generateCryptoRandomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._~';
    final Random random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
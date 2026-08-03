import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';
import 'package:paytonpieper/features/weather_alerts/controller/bite_watch_controller.dart';

class GoogleLoginController extends GetxController {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NetworkCaller _networkCaller = NetworkCaller();

  final RxBool isLoading = false.obs;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NetworkCaller _networkCaller = NetworkCaller();

  Future<void>? _initialization;
  bool _isSigningIn = false;

  Future<void> continueWithGoogle() async {
    isLoading.value = true;
    await EasyLoading.show(status: 'Signing in with Google...');
    if (_isSigningIn) return;
    _isSigningIn = true;

    var loginSucceeded = false;
    await EasyLoading.show(status: 'Signing in...');
    try {
      await _ensureInitialized();

      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      AppLoggerHelper.info(
        'Google Sign-In success: '
        'email=${googleUser.email}, '
        'name=${googleUser.displayName}, '
        'id=${googleUser.id}',
      );

      final googleIdToken = googleAuth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        AppLoggerHelper.error(
          'Google Sign-In failed: Google authentication did not return an idToken.',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In failed',
          message: 'Google authentication did not return a valid token.',
          backgroundColor: Colors.red,
        );
        return;
      }

      AppLoggerHelper.info('Google account id: ${googleUser.id}');
      AppLoggerHelper.info('Google idToken: $idToken');

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      AppLoggerHelper.info(
        'Firebase Google auth success: uid=${user?.uid}',
      );

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

      // Extract user name
      final String name = googleUser.displayName ?? user?.displayName ?? '';
      final userId = user?.uid ?? googleUser.id;

      // Call backend socialLogin API matching schema:
      // { "idToken": "...", "provider": "GOOGLE", "fcmToken": "...", "name": "..." }
      final Map<String, dynamic> requestBody = {
        'idToken': idToken,
        'provider': 'GOOGLE',
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
          title: 'Google Sign-In Failed',
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      AppLoggerHelper.info(
        'Firebase Google auth success: uid=${firebaseUser?.uid}',
      );

      if (firebaseUser == null) {
        AppLoggerHelper.error(
          'Firebase Google auth did not return an authenticated user.',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In failed',
          message: 'Firebase authentication could not verify this account.',
          backgroundColor: Colors.red,
        );
        return;
      }

      final freshFcmToken = await _firebaseMessaging.getToken();
      final fcmToken = freshFcmToken ?? StorageService.fcmToken;
      if (fcmToken == null || fcmToken.isEmpty) {
        AppLoggerHelper.error(
          'Google social login could not obtain an FCM token.',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In failed',
          message: 'Unable to register this device. Please try again.',
          backgroundColor: Colors.red,
        );
        return;
      }

      if (freshFcmToken != null && freshFcmToken.isNotEmpty) {
        await StorageService.saveFcmToken(freshFcmToken);
      }

      final displayName = googleUser.displayName?.trim().isNotEmpty == true
          ? googleUser.displayName!.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty == true
                ? firebaseUser.displayName!.trim()
                : googleUser.email.split('@').first);

      final response = await _networkCaller.postRequest(
        ApiConstants.socialLoginApi,
        body: {
          'idToken': googleIdToken,
          'provider': 'GOOGLE',
          'fcmToken': fcmToken,
          'name': displayName,
        },
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          'Google social login failed: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In failed',
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

      if (accessToken is String && accessToken.isNotEmpty) {
        await StorageService.saveAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken is String ? refreshToken : '',
        );
        if (userId.isNotEmpty) {
          await StorageService.saveUserId(userId);
        }
        AppLoggerHelper.info('Social login successful and auth tokens saved.');

        try {
          final biteCtrl = Get.find<BiteWatchController>();
          await biteCtrl.uploadFcmToken();
          await biteCtrl.fetchWatchedZones();
        } catch (e) {
          AppLoggerHelper.error(
            'Failed to sync FCM / watched zones on Google login',
            e,
          );
        }

        Get.offAll(() => MainScreen());
      } else {
        AppLoggerHelper.error(
          'Social Login response missing accessToken. Full response: $responseBody',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In Failed',
          message:
              'Login succeeded but session could not be established. Please try again.',
          backgroundColor: Colors.red,
        );
      }
      if (accessToken is! String ||
          accessToken.isEmpty ||
          refreshToken is! String ||
          refreshToken.isEmpty) {
        AppLoggerHelper.error(
          'Google social login response did not contain valid auth tokens.',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In failed',
          message: 'The server returned an invalid login response.',
          backgroundColor: Colors.red,
        );
        return;
      }

      await StorageService.saveAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      AppLoggerHelper.info(
        'Google social login successful and auth tokens saved.',
      );
      loginSucceeded = true;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        AppLoggerHelper.info('Google Sign-In cancelled by user.');
        return;
      }

      AppLoggerHelper.error(
        'Google Sign-In failed: ${error.code} - ${error.description}',
        error,
      );
      CommonMessage.showMessage(
        title: 'Google Sign-In failed',
        message: error.description ?? 'Unable to sign in with Google.',
        backgroundColor: Colors.red,
      );
    } on FirebaseAuthException catch (error) {
      AppLoggerHelper.error(
        'Firebase Google auth failed: ${error.code} - ${error.message}',
        error,
      );
      CommonMessage.showMessage(
        title: 'Google Sign-In failed',
        message: error.message ?? 'Unable to authenticate with Firebase.',
        backgroundColor: Colors.red,
      );
    } catch (error) {
      AppLoggerHelper.error('Google Sign-In failed unexpectedly', error);
      CommonMessage.showMessage(
        title: 'Google Sign-In failed',
        message: 'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
      await EasyLoading.dismiss();
      _isSigningIn = false;
    }

    if (loginSucceeded) {
      Get.offAll(() => MainScreen());
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize()
      ..catchError((dynamic error) {
        _initialization = null;
        throw error;
      });
  }
}

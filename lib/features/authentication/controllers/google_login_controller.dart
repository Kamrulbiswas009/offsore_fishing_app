import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/main_screen/screen/home_main_screen.dart';

class GoogleLoginController extends GetxController {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void>? _initialization;

  Future<void> continueWithGoogle() async {
    await EasyLoading.show(status: 'Signing in...');
    try {
      await _ensureInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        AppLoggerHelper.error(
          'Google Sign-In failed: authenticate is not supported on this platform.',
        );
        CommonMessage.showMessage(
          title: 'Google Sign-In failed',
          message: 'Google Sign-In is not supported on this platform.',
          backgroundColor: Colors.red,
        );
        return;
      }

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = await _getGoogleAccessToken(googleUser);

      AppLoggerHelper.info(
        'Google Sign-In success: '
        'email=${googleUser.email}, '
        'name=${googleUser.displayName}, '
        'id=${googleUser.id}',
      );

      if (idToken == null || idToken.isEmpty) {
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
      AppLoggerHelper.info('Google accessToken: ${accessToken ?? 'null'}');

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await userCredential.user?.getIdToken();

      AppLoggerHelper.info(
        'Firebase Google auth success: uid=${userCredential.user?.uid}',
      );
      AppLoggerHelper.info('Firebase idToken: ${firebaseIdToken ?? 'null'}');
      Get.offAll(() =>  MainScreen());
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
      await EasyLoading.dismiss();
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize()
      ..catchError((dynamic error) {
        _initialization = null;
        throw error;
      });
  }

  Future<String?> _getGoogleAccessToken(GoogleSignInAccount googleUser) async {
    try {
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(const <String>['email', 'profile']);
      if (authorization != null) return authorization.accessToken;

      final promptedAuthorization = await googleUser.authorizationClient
          .authorizeScopes(const <String>['email', 'profile']);
      return promptedAuthorization.accessToken;
    } on GoogleSignInException catch (error) {
      AppLoggerHelper.error(
        'Google access token request failed: ${error.code} - ${error.description}',
        error,
      );
      return null;
    } catch (error) {
      AppLoggerHelper.error('Google access token request failed.', error);
      return null;
    }
  }
}

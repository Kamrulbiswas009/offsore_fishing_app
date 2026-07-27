# iOS Apple Sign-In Setup & Implementation Guide

**Bundle ID**: `com.onthebite.app.ios`  
**Framework**: Flutter (Dart)  
**State Management**: GetX (`GetxController`)  
**Backend**: Firebase Authentication  

---

## 1. What Was Implemented

### A. Dependencies Added (`pubspec.yaml`)
- `sign_in_with_apple: ^6.1.4` – Provides native iOS Apple Sign-In dialogs and credential retrieval.
- `crypto: ^3.0.3` – Used to generate SHA-256 hashes of cryptographically secure random nonces for OpenID Connect security compliance.
- `firebase_auth: ^6.5.4` – Generates and authenticates Apple OAuth credentials with Firebase Auth.
- `get: ^4.7.3` – Manages reactive UI state (`RxBool`) and dependency binding.

### B. Files Created / Modified

1. **`AppleLoginController`**  
   - **Path**: [`lib/features/authentication/controllers/apple_login_controller.dart`](file:///Users/betopia/kamrul_Project/paytonpieper/lib/features/authentication/controllers/apple_login_controller.dart)
   - Handles device compatibility check via `SignInWithApple.isAvailable()`.
   - Generates a cryptographically secure 32-character raw nonce and its SHA-256 digest.
   - Requests Apple authorization credentials (`email`, `fullName` scopes).
   - Generates Firebase `OAuthCredential` using `OAuthProvider('apple.com').credential(...)`.
   - Authenticates user against Firebase Auth via `signInWithCredential(credential)`.
   - Manages reactive `isLoading` state (`RxBool`).
   - Catches `SignInWithAppleAuthorizationException` and gracefully ignores user cancellation (`AuthorizationErrorCode.canceled`) without showing error dialogs.

2. **`AppleSignInButton` Widget**  
   - **Path**: [`lib/features/authentication/presentation/widgets/auth_common_widgets.dart`](file:///Users/betopia/kamrul_Project/paytonpieper/lib/features/authentication/presentation/widgets/auth_common_widgets.dart)
   - Observers `AppleLoginController.isLoading` via GetX `Obx`.
   - Displays a `CircularProgressIndicator` inside the button while processing.

3. **`LoginScreen` Update**  
   - **Path**: [`lib/features/authentication/presentation/screens/login_screen.dart`](file:///Users/betopia/kamrul_Project/paytonpieper/lib/features/authentication/presentation/screens/login_screen.dart)
   - Integrated `AppleSignInButton` connected to `appleLoginController`.

4. **`ControllerBinder` Registration**  
   - **Path**: [`lib/core/bindings/controller_binder.dart`](file:///Users/betopia/kamrul_Project/paytonpieper/lib/core/bindings/controller_binder.dart)
   - `AppleLoginController` registered via `Get.lazyPut<AppleLoginController>(() => AppleLoginController(), fenix: true);`.

---

## 2. Requirements & Configuration Steps Needed

### Step 1: Xcode Configuration (iOS App)
1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. In Xcode, select **Runner** in the left sidebar.
3. Select the **Runner** target > Navigate to the **Signing & Capabilities** tab.
4. Verify **Bundle Identifier** is set to `com.onthebite.app.ios`.
5. Click **+ Capability** at the top left.
6. Double-click **Sign in with Apple**.
7. Confirm that `Runner.entitlements` file is generated with the `com.apple.developer.applesignin` key.

---

### Step 2: Apple Developer Portal Setup
1. Log in to [Apple Developer Account](https://developer.apple.com/account/).
2. Go to **Certificates, Identifiers & Profiles** > **Identifiers** > **App IDs**.
3. Locate App ID `com.onthebite.app.ios` (or create it if not already present).
4. Under **Capabilities**, ensure **Sign in with Apple** is checked (configured as Primary App ID).
5. Save changes.

---

### Step 3: Firebase Console Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Select your project > Navigate to **Authentication** > **Sign-in method**.
3. Under **Additional providers**, click **Apple**.
4. Enable the provider.
5. Fill in the required Apple Developer details:
   - **Services ID** (optional for native iOS, required for Web/Android).
   - **OAuth code flow configuration** (Apple Team ID, Key ID, Private Key `.p8`).
6. Click **Save**.

---

## 3. How to Test Apple Sign-In

1. **On Physical iOS Device (Recommended)**:
   - Connect physical iPhone/iPad running iOS 13+.
   - Run the application:
     ```bash
     flutter run -d <your-device-id>
     ```
   - Tap **Apple** button on the Login Screen.
   - Confirm Face ID / Touch ID / Apple ID Password prompt.
   - Verify user redirection to MainScreen upon success.

2. **On iOS Simulator**:
   - iOS Simulator (iOS 13+) supports Sign in with Apple if signed into an Apple ID in **Settings > Sign in to your iPhone** on the simulator.

3. **User Cancellation Test**:
   - Tap Apple Sign-In button, then press **Cancel** on the system sheet.
   - App should quietly return to idle state without showing red error banners.

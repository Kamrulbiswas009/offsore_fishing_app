/// App Identity & Package Configuration Guide
///
/// This file documents the package name, display name, and launcher icon configurations
/// for the **On The Bite** app, including historical values and step-by-step commands.
///
/// ## Identity History
/// - **Original App Display Name**: `paytonpieper`
/// - **Updated App Display Name**: `On The Bite`
/// - **Original Package Name (Android) / Bundle Identifier (iOS)**: `com.example.paytonpieper`
/// - **Updated Package Name (Android) / Bundle Identifier (iOS)**: `com.onthebite.app`
/// - **Launcher Icon Path**: `assets/icons/app_icon.png`
///
/// ---
///
/// ## How to Update the App Icon & Name
///
/// ### 1. Changing the App Icon
/// 1. Copy the new image to `assets/icons/app_icon.png`.
/// 2. Run the icon generator:
///    ```bash
///    dart run flutter_launcher_icons
///    ```
///
/// ### 2. Changing the Package Name (Bundle Identifier)
/// 1. Run the renaming command:
///    ```bash
///    dart run change_app_package_name:main com.newname.app
///    ```
/// 2. **Important**: Since the app uses Firebase, update these configurations:
///    - **Android**: `android/app/google-services.json` (update the `"package_name"` fields)
///    - **iOS**: `ios/Runner/GoogleService-Info.plist` (update the `BUNDLE_ID` value)
///    - **Dart**: `lib/firebase_options.dart` (update the `iosBundleId` field)
///
/// ### 3. Changing the App Display Name (Name under the icon)
/// - **Android**: In `android/app/src/main/AndroidManifest.xml`, update the `android:label` attribute of `<application>`:
///   `android:label="On The Bite"`
///
/// - **iOS**: In `ios/Runner/Info.plist`, update `CFBundleDisplayName` and `CFBundleName`:
///   `<key>CFBundleDisplayName</key><string>On The Bite</string>`
///   `<key>CFBundleName</key><string>On The Bite</string>`
///
/// ---
///
/// ## Troubleshooting Build Failures (Clearing Cache)
/// If you encounter compile failures (such as `Dex file is empty` or `mergeLibDexDebug failed`) after a package name change:
/// ```bash
/// flutter clean
/// flutter pub get
/// cd android
/// ./gradlew clean
/// ```
const Map<String, String> appIdentityHistory = {
  'previousAppName': 'paytonpieper',
  'currentAppName': 'On The Bite',
  'previousPackageName': 'com.example.paytonpieper',
  'currentPackageName': 'com.onthebite.app',
  'appIconPath': 'assets/icons/app_icon.png',
};

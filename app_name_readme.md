# App Identity & Package Configuration Guide

This guide documents the package name, display name, and launcher icon configurations for the **On The Bite** app, including historical values and step-by-step commands to quickly update them in the future.

---

## Identity History

| Attribute | Original Value (Previous) | Updated Value (Current) |
| :--- | :--- | :--- |
| **App Display Name** | `paytonpieper` | `On The Bite` |
| **Package Name / Application ID** | `com.example.paytonpieper` | `com.onthebite.app` |
| **Dart Package Name** | `paytonpieper` | `paytonpieper` |
| **Launcher Icon Path** | Default Flutter Icons | `assets/icons/app_icon.png` |

---

## Packages Used

1. **`flutter_launcher_icons`** (v0.13.1+) - Automates the generation and replacement of Android and iOS launcher icons from a single source image.
2. **`change_app_package_name`** (v1.4.0+) - Automates renaming the Android package name/application ID and iOS bundle identifier across all native configuration files.

---

## How to Update the App Icon & Name

### 1. Changing the App Icon

If you have a new icon image (e.g., `new_icon.png`), follow these steps:

1. Copy the new image to `assets/icons/app_icon.png` (or place it anywhere and update the `image_path` in `pubspec.yaml`).
2. Run the icon generator:
   ```bash
   dart run flutter_launcher_icons
   ```

*Note: For iOS, to avoid App Store submission rejections, you can configure it to strip the alpha channel by adding `remove_alpha_ios: true` in the `flutter_launcher_icons` configuration block in `pubspec.yaml`.*

### 2. Changing the Package Name (Bundle Identifier)

To change the Android package name (Application ID) and iOS Bundle Identifier (e.g., to `com.newname.app`):

1. Run the renaming command:
   ```bash
   dart run change_app_package_name:main com.newname.app
   ```
2. **Important**: Since the app uses Firebase, you must also update:
   - Android: `android/app/google-services.json` (update the `"package_name"` fields)
   - iOS: `ios/Runner/GoogleService-Info.plist` (update the `BUNDLE_ID` value)
   - Dart: `lib/firebase_options.dart` (update the `iosBundleId` field)
   
   *(If moving to production, download the fresh configuration files from the Firebase Developer Console after registering the new package identifier).*

### 3. Changing the App Display Name (Name under the icon)

To change the user-facing app name on the home screen:

* **Android**: Open [AndroidManifest.xml](file:///Users/betopia/kamrul's%20Project/paytonpieper/android/app/src/main/AndroidManifest.xml) and update the `android:label` attribute:
  ```xml
  <application
      android:label="On The Bite"
      ...
  ```

* **iOS**: Open [Info.plist](file:///Users/betopia/kamrul's%20Project/paytonpieper/ios/Runner/Info.plist) and update the `CFBundleDisplayName` and `CFBundleName` values:
  ```xml
  <key>CFBundleDisplayName</key>
  <string>On The Bite</string>
  ...
  <key>CFBundleName</key>
  <string>On The Bite</string>
  ```

---

## Troubleshooting Build Failures (Clearing Cache)

If you rename the package and encounter compilation errors such as `Dex file is empty` or `mergeLibDexDebug failed` due to stale compiler artifacts, run these clean commands:

```bash
# Clean Flutter build artifacts
flutter clean

# Get dependencies
flutter pub get

# Clean Gradle internal compiler caches
cd android
./gradlew clean
```

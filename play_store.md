# 🚀 Google Play Store Release & Submission Guide: On The Bite

This document provides a comprehensive, end-to-end technical guide and console walkthrough for publishing **On The Bite** (`com.onthebite.app`) to the **Google Play Store**.

---

## 📑 Table of Contents
1. [App Identity & Technical Specifications](#1-app-identity--technical-specifications)
2. [Android Permissions Analysis](#2-android-permissions-analysis)
3. [Third-Party Services & Dependencies](#3-third-party-services--dependencies)
4. [Android Release Signing Configuration](#4-android-release-signing-configuration)
5. [Building the Production App Bundle (.aab)](#5-building-the-production-app-bundle-aab)
6. [Google Play Console Step-by-Step Walkthrough](#6-google-play-console-step-by-step-walkthrough)
   - [A. App Details & Store Listing Copy](#a-app-details--store-listing-copy)
   - [B. Graphic Assets Requirements](#b-graphic-assets-requirements)
   - [C. Sign In Details (App Access)](#c-sign-in-details-app-access)
   - [D. Content Ratings (IARC Questionnaire)](#d-content-ratings-iarc-questionnaire)
   - [E. Target Audience & Content](#e-target-audience--content)
   - [F. Data Safety Section (Exhaustive Answers)](#f-data-safety-section-exhaustive-answers)
   - [G. Other Policy Declarations](#g-other-policy-declarations)
7. [Testing Tracks & The 20 Testers / 14-Day Rule](#7-testing-tracks--the-20-testers--14-day-rule)
8. [Top Play Store Rejection Pitfalls & Solutions](#8-top-play-store-rejection-pitfalls--solutions)

---

## 1. App Identity & Technical Specifications

| Parameter | Value | Location in Codebase |
| :--- | :--- | :--- |
| **App Name** | `On The Bite` | `android/app/src/main/AndroidManifest.xml` |
| **Application ID / Package Name** | `com.onthebite.app` | `android/app/build.gradle.kts` |
| **Android Namespace** | `com.onthebite.app` | `android/app/build.gradle.kts` |
| **Current Version Name** | `1.0.0` | `pubspec.yaml` (`version: 1.0.0+1`) |
| **Current Version Code** | `1` | `pubspec.yaml` (`version: 1.0.0+1`) |
| **Minimum Android SDK** | `23` (Android 6.0 Marshmallow) | `android/app/build.gradle.kts` |
| **Target Android SDK** | `34+` (Android 14+) | Flutter Gradle Plugin Default |
| **Compile Android SDK** | `35` (Android 15) | Flutter Gradle Plugin Default |
| **Core Frameworks** | Flutter 3.47.2, Dart 3.13.2 | Project Environment |

> [!IMPORTANT]
> For every subsequent update uploaded to Google Play Console, you must increment the **build number** in `pubspec.yaml` (e.g., `version: 1.0.1+2`, then `1.0.2+3`). Google Play rejects uploads with duplicate version codes.

---

## 2. Android Permissions Analysis

The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:

| Permission | Purpose in "On The Bite" | Play Store Policy Notes |
| :--- | :--- | :--- |
| `android.permission.INTERNET` | Communicates with backend APIs, Mapbox tiles, Firebase, and weather services. | Standard normal permission. |
| `android.permission.ACCESS_FINE_LOCATION` | Pinpoints angler's GPS position on offshore marine maps and fetches local weather/tides. | Dangerous permission. Requires in-app runtime dialog and explanation in Data Safety. |
| `android.permission.ACCESS_COARSE_LOCATION` | Approximate location for regional weather and bite forecast zones. | Dangerous permission. Declared together with fine location. |
| `android.permission.POST_NOTIFICATIONS` | Delivers real-time push alerts for severe weather, bite watches, and crew messages (Android 13+). | Runtime prompt required before posting notifications. |
| `android.permission.READ_MEDIA_IMAGES` | Lets users select photos from gallery for catch reports and profile pictures (Android 13+). | Scoped media permission. |
| `android.permission.READ_EXTERNAL_STORAGE` | Backward compatibility for Android 12 and below (`maxSdkVersion="32"`). | Properly scoped with `maxSdkVersion`. |
| `android.permission.WRITE_EXTERNAL_STORAGE` | Backward compatibility for Android 12 and below (`maxSdkVersion="32"`). | Properly scoped with `maxSdkVersion`. |

> [!NOTE]
> `ACCESS_BACKGROUND_LOCATION` is **not** requested. This is advantageous because Google Play imposes severe review restrictions and audit questionnaires on background location.

---

## 3. Third-Party Services & Dependencies

The app integrates the following third-party SDKs that collect data or communicate externally:

1. **Firebase Authentication (`firebase_auth`)**: Handles email/password, Google Sign-In, and Apple Sign-In.
2. **Firebase Cloud Messaging (`firebase_messaging`, `flutter_local_notifications`)**: Manages device push notification tokens and alerts.
3. **Mapbox Maps (`mapbox_maps_flutter`)**: Renders bathymetric marine charts, satellite layers, and handles offline tile downloads.
4. **Stripe (`flutter_stripe`)**: Handles checkout and payment sheets for digital Pro subscription tiers.
5. **Geolocator (`geolocator`)**: Acquires device coordinates for GPS positioning.
6. **Image Picker (`image_picker`)**: Selects photos from the user's camera or photo gallery.

---

## 4. Android Release Signing Configuration

Google Play requires all release builds to be cryptographically signed with an upload key.

### Step 1: Generate Release Keystore
Run the following command in your terminal from the project root:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

*When prompted, enter a secure password (e.g. 8+ characters) and basic organization details. Note down your password.*

### Step 2: Create `android/key.properties`
Create a file at `android/key.properties` containing:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

*(Replace `YOUR_KEYSTORE_PASSWORD` and `YOUR_KEY_PASSWORD` with the passwords you set in Step 1).*

### Step 3: Configure `android/app/build.gradle.kts`
Ensure `android/app/build.gradle.kts` contains the release signing configuration:

```kotlin
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### Step 4: Protect Keystore in Git
Verify that `android/.gitignore` and root `.gitignore` include:
```gitignore
key.properties
**/*.keystore
**/*.jks
```

---

## 5. Building the Production App Bundle (.aab)

Google Play Store exclusively accepts **Android App Bundles (`.aab`)** for new apps.

Run the release build command:

```bash
flutter build appbundle --release
```

Once completed, the release bundle will be available at:
`build/app/outputs/bundle/release/app-release.aab`

This is the exact file you upload to the Google Play Console track.

---

## 6. Google Play Console Step-by-Step Walkthrough

### A. App Details & Store Listing Copy

* **App name**: `On The Bite` *(max 30 characters)*
* **Short description**: *(max 80 characters)*
  `Offshore fishing intel, marine weather alerts, bathymetric maps & catch logging`
* **Full description**: *(max 4000 characters)*
  ```text
  On The Bite is the ultimate offshore fishing intelligence and marine navigation companion built for serious saltwater anglers, captains, and crew.

  KEY FEATURES:

  • REAL-TIME OFFSHORE INTEL: Access community-driven reports, verified bite activity, and hot spots updated by local crews and offshore anglers.
  • BATHYMETRIC & SATELLITE MAPS: Explore high-definition marine contours, temperature breaks, and depth gradients powered by vector mapping with offline capabilities.
  • MARINE WEATHER & TIDES: Plan every trip safely with precision barometric pressure, wind speeds, wave heights, and tidal forecasts.
  • BITE WATCH ALERTS: Get instant push alerts when prime bite windows open in your monitored zones based on moon phase, water temperature, and barometric trends.
  • CATCH LOGGING: Document your catches with GPS coordinates, photos, weather conditions, tackle specs, and personal catch notes.
  • CREW GROUPS & SECURE CHAT: Form private fishing teams, share secret coordinates, and exchange real-time marine intel with your trusted crew.

  Whether you are trolling offshore for pelagics or bottom fishing the reefs, On The Bite gives you the data you need to find the fish faster.

  Privacy Policy: https://docs.google.com/presentation/d/1yxnsA-50zWnUfibbG7Rc7ajzKwknOnR5k58aybXy6OE/edit?usp=sharing
  Terms of Use: https://docs.google.com/presentation/d/1OilGUp8DNx2qGDA4FtKlDhhSOvPf8qlwbHTFS5iUsKs/edit?usp=sharing
  ```

---

### B. Graphic Assets Requirements

1. **App Icon**:
   - Size: `512 x 512 px`
   - Format: `32-bit PNG`
   - Max file size: `1 MB`
   - Source in project: `assets/icons/app_icon.png` (resize to exact 512x512).
2. **Feature Graphic**:
   - Size: `1024 x 500 px`
   - Format: `JPEG or 24-bit PNG` (no alpha)
   - Max file size: `15 MB`
   - Content: Clean brand artwork showing "On The Bite" logo and marine/offshore visual.
3. **Phone Screenshots**:
   - Minimum: `2 screenshots` (Maximum: `8 screenshots`).
   - Dimensions: Between `320 px` and `3840 px` (Standard: `1080 x 1920` or `1080 x 2400` in 9:16 aspect ratio).
   - Recommended screens to capture:
     1. Live Zone Marine Map & Contours
     2. Weather & Bite Forecast Dashboard
     3. Catch Report Logging Screen
     4. Crew Group Activity & Feed

---

### C. Sign In Details (App Access)

* **Is any part of your app restricted?**
  👉 **Yes**
* Click **+ Add instructions** and fill out:
  - **Instruction name**: `Reviewer Demo Account`
  - **Username / Email**: `[A valid test email created in your Firebase Auth]`
  - **Password**: `[The test account password]`
  - **Any other instructions**:
    ```text
    Log in using the provided email and password. No 2FA or SMS verification is required. This account provides full access to view map zones, weather alerts, catch reports, and settings.
    ```

---

### D. Content Ratings (IARC Questionnaire)

* **Email address**: Your developer/contact email.
* **Category**: **All Other App Types**
* **Downloaded App**:
  - Contains ratings-relevant content (sex, violence, language)? 👉 **No**
* **User Content Sharing**:
  - Allows users to interact/exchange content (chat, reports, photos)? 👉 **Yes**
  - Share user's current and precise physical location with other users? 👉 **No**
  - Can interactions be limited to invited friends only? 👉 **No**
  - Permits public sharing of nudity? 👉 **No**
  - Permits sharing of graphic violence? 👉 **No**
  - Ability to block users? 👉 **No**
  - Ability to report users? 👉 **No**
  - Chat moderation? 👉 **No**
  - Is shared user content the primary source of content? 👉 **No**
* **Online Content**:
  - Feature or promote content outside download (open browser)? 👉 **No**
* **Promotion or Sale of Age-Restricted Products**:
  - Promote alcohol, tobacco, firearms, gambling? 👉 **No**
* **Miscellaneous**:
  - Allows users to purchase digital goods? 👉 **Yes**
  - Loot boxes / random drops / chance-based items? 👉 **No**
  - Cryptocurrency, NFTs, or cash rewards? 👉 **No**
  - Web browser or search engine? 👉 **No**
  - Primarily news or educational? 👉 **No**

---

### E. Target Audience & Content

* **Target age group**: **18 and over** (Checked).
* **Restrict users that Google has determined to be minors**: **Unchecked** (Leave unchecked).
* **Appeal to children**: **No**.

---

### F. Data Safety Section (Exhaustive Answers)

Google Play mandates accurate declaration of all collected data.

#### Initial Questions:
1. **Does your app collect or share any of the required user data types?** 👉 **Yes**
2. **Is all of the user data collected by your app encrypted in transit?** 👉 **Yes** *(via HTTPS / TLS)*
3. **Do you provide a way for users to request that their data be deleted?** 👉 **Yes** *(App provides in-app account deletion under Settings ➔ Delete Account)*
4. **Link to request deletion**: Provide your Privacy Policy URL or Support email link.

#### Data Types Breakdown to Declare:

| Data Category | Specific Data Type | Collected? | Shared? | Ephemeral? | Required / Optional? | Purposes to Check |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Location** | Approximate Location | Yes | No | No | Required | App functionality |
| **Location** | Precise Location | Yes | No | No | Required | App functionality |
| **Personal Info** | Name | Yes | No | No | Optional | App functionality, Account management |
| **Personal Info** | Email Address | Yes | No | No | Required | App functionality, Account management |
| **Personal Info** | User IDs (Firebase UID) | Yes | No | No | Required | App functionality, Account management |
| **Financial Info** | Purchase History / Payment Info | Yes | No | No | Optional | App functionality (via Stripe) |
| **Photos and Videos**| Photos | Yes | No | No | Optional | App functionality (Catch logs & profile avatar) |
| **App Info & Performance**| Crash Logs / Diagnostics | Yes | No | No | Required | Analytics, Diagnostics |
| **Device or other IDs**| Device IDs (FCM Push Token) | Yes | No | No | Required | App functionality (Push notifications) |

---

### G. Other Policy Declarations

* **Ads**: Select **"No, my app does not contain ads"**.
* **Financial Features**: Select **"My app doesn't provide any financial features"** *(Selling an in-app subscription is standard digital purchase, not a banking, loan, or investment product)*.
* **Government Apps**: Select **"No"**.
* **Health Apps**: Select **"My app is not a health app"**.

---

## 7. Testing Tracks & The 20 Testers / 14-Day Rule

> [!IMPORTANT]
> **Google's Policy for Personal Developer Accounts (Created after Nov 13, 2023):**
> Before you are allowed to release to **Production**, Google requires you to run a **Closed Test** with at least **20 testers opted-in continuously for at least 14 days**.

### Recommended Deployment Sequence:
1. **Internal Testing Track (Instant)**:
   - Upload `app-release.aab`.
   - Add your own email to internal testers list.
   - Instantly available without Google review for immediate testing on real Android phones.
2. **Closed Testing Track (Alpha/Beta)**:
   - Create a closed track (e.g. "Alpha Closed Track").
   - Upload the `.aab`.
   - Create an email list containing at least 20 testers (friends, team members, or beta community).
   - Send the opt-in link to all 20 testers.
   - All 20 testers must click "Join on Android / Web" and download the app.
   - Keep the test active for **14 consecutive days**.
3. **Apply for Production Access**:
   - After 14 days, the button **"Apply for production"** will unlock on your Play Console dashboard.
   - Answer a short questionnaire about tester engagement and feedback.
   - Once Google grants production approval, you can roll out to **Production** (All users).

---

## 8. Top Play Store Rejection Pitfalls & Solutions

1. **Broken or Inactive Demo Credentials**:
   - Reviewers test on physical Google Pixel devices. If the demo login fails or requests an SMS OTP that the reviewer cannot enter, the build will be rejected. Always verify the demo account logs in smoothly.
2. **Missing Prominent Location Disclosure**:
   - Before requesting `ACCESS_FINE_LOCATION`, the app should show a brief in-app prompt explaining: *"On The Bite accesses your location to display marine weather, sea surface conditions, and fishing zones near you."*
3. **Privacy Policy Accessibility**:
   - Google requires the Privacy Policy link to be active, publicly accessible without login, and clearly reference the app name or developer entity.
4. **Google Play Billing vs Stripe**:
   - Google Play policy mandates using **Google Play In-App Billing** for digital content consumed inside Android apps (such as subscription unlocks for maps and forecasts). Ensure you transition digital unlocks to Google Play Billing or consult Google's alternative billing policies to avoid payment compliance flags.

---

*Generated for **On The Bite** (`com.onthebite.app`) — Future-Stack / paytonpieper.*

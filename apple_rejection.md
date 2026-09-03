# On The Bite — App Store Rejection Review

Codebase audit against Apple’s current [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/). Ranked by how likely each issue is to cause a rejection.

Metadata in App Store Connect (privacy labels, screenshots, review notes, Support URL) is not in this repo and must be checked separately.

---

## Most likely rejection: Guideline 3.1.1

The app sells a **$9.99/month Pro plan** that unlocks in-app digital features (live heatmap, real-time reports, group creation, 5-day forecast, fishing notifications) through **Stripe PaymentSheet**.

Digital unlocks on iOS **must** use Apple In-App Purchase. Stripe is allowed only for physical goods or services consumed outside the app. This is not a reader app, so Guideline 3.1.3(a) does not apply.

---

## Summary

| Metric | Count |
|---|---|
| Must-fix before resubmit | 1 (Stripe → StoreKit) |
| Guideline issues found | 10 |
| P0 blockers | 3 |
| Already in good shape | 4 |

---

## All findings

| Pri | Guideline | Problem | Where | Likelihood |
|---|---|---|---|---|
| P0 | 3.1.1 / 3.1.2 | Stripe sells digital Pro features | `payment_service_controller.dart`, `profile_main_screen.dart` | Almost certain |
| P0 | 5.1.1(i) | Privacy Policy and Terms are Google Slides | `settings_screen_controller.dart` | Very likely |
| P0 | 5.1.1(ii) | Permission strings do not match real use | `ios/Runner/Info.plist` | Very likely |
| P1 | 1.2 | UGC has no report, block, or filter | groups chat, public reports, profile photos | Very likely |
| P1 | 2.1 / 2.3.1 | Placeholder and mock content in the binary | `subscription_plan_controller.dart`, `map_screen_controller.dart` | Likely |
| P1 | Privacy Manifest | No `PrivacyInfo.xcprivacy` in the iOS target | `ios/Runner/` | Likely (upload or review) |
| P1 | 5.1.1(v) | Account delete does not revoke Sign in with Apple | `settings_screen_controller.dart`, `apple_login_controller.dart` | Likely |
| P2 | 1.5 | In-app support is static text, email is not tappable | `help_and_support_screen.dart` | Possible |
| P2 | 2.1 | Login-gated app with no in-binary demo account | `login_screen.dart`, `splash_screen_controller.dart` | Possible |
| P2 | 3.1.2(c) | No auto-renew terms, privacy/ToS, or Restore before pay | `payment_service_controller.dart` | Follow-on after IAP |

---

## 1. Replace Stripe with StoreKit subscriptions

**Guidelines:** 3.1.1 In-App Purchase, 3.1.2 Subscriptions, 3.1.2(c) Subscription Information, 3.1.3(b) Multiplatform Services

Pro is software-as-a-service inside the iOS app: delayed vs live reports, heatmap, groups, weather length, and notifications.

Apple’s wording: *If you want to unlock features or functionality within your app (subscriptions, access to premium content, unlocking a full version), you must use in-app purchase. Apps may not use their own mechanisms to unlock content or functionality.*

The UI even says: “Secure payments powered by Stripe.”

### Where

- `lib/features/payment_service/controller/payment_service_controller.dart`
  - `confirmSelectedPlan()` creates a Stripe Payment Intent, then `Stripe.instance.presentPaymentSheet()`.
- `lib/features/profile_and_setting/presentation/screen/profile_main_screen.dart`
  - “Unlock Pro >” button and Stripe copy.
- `lib/features/profile_and_setting/model/auth_me_model.dart`
  - `stripeCustomerId`, `stripeSubscriptionId`, `stripePriceId`.
- `lib/features/payment_service/model/payment_plan_model.dart`
  - `stripeProductId`, `stripePriceId`.
- `lib/core/utils/constants/api_constants.dart`
  - `/subscriptions/intent`, `/subscriptions/cancel`, `/subscriptions/reactivate`.
- `pubspec.yaml`
  - `flutter_stripe: ^11.5.0`.

### How to sort it out

1. Create an auto-renewable subscription in App Store Connect (e.g. monthly Pro). Use StoreKit 2 (`in_app_purchase` or RevenueCat).
2. On iOS only, present Apple’s purchase sheet — never Stripe.
3. Add **Restore Purchases** (required for restorable IAP).
4. Before buy, show duration, price, what renews, and links to Privacy Policy and Terms (3.1.2(c) / Schedule 2 of the Apple Developer Program License Agreement).
5. Validate Apple receipts on the server and map them to Pro.
6. Let users who already bought on web keep access (3.1.3(b)), but still offer the same plan via IAP inside the iOS app.
7. Remove `flutter_stripe` from the iOS target, or compile it out with a `Platform.isIOS` guard and drop the Stripe camera usage string.
8. Delete the “Future Premium Features” row — you cannot sell unspecified future content (2.1 / 2.3.1).

**Note:** US storefront External Purchase Link (3.1.1(a)) does not replace IAP for feature unlocks, and you still cannot run a native Stripe card sheet for digital goods.

---

## 2. Ship a real Privacy Policy and Terms URL

**Guideline:** 5.1.1(i) Privacy Policies

All apps must include a link to their privacy policy in the App Store Connect metadata field **and** within the app in an easily accessible manner. The policy must clearly and explicitly:

- Identify what data the app collects, how it collects that data, and all uses of that data.
- Confirm that any third party with whom the app shares user data will provide the same or equal protection.
- Explain data retention/deletion policies and describe how a user can revoke consent and/or request deletion.

### Where

`lib/features/profile_and_setting/controller/settings_screen_controller.dart` — `handleAboutItemTap()`:

- Privacy Policy → `https://docs.google.com/presentation/d/1yxnsA-50zWnUfibbG7Rc7ajzKwknOnR5k58aybXy6OE/edit?usp=sharing`
- Terms of Use → `https://docs.google.com/presentation/d/1OilGUp8DNx2qGDA4FtKlDhhSOvPf8qlwbHTFS5iUsKs/edit?usp=sharing`

The same Google Slides Privacy Policy URL is also used on the subscription screen in `profile_main_screen.dart`.

Reviewers treat Google Slides as a missing or non-functional policy: it is not a policy page, may require a Google login, and does not clearly state data types, third parties (Firebase, Mapbox, StormGlass, Stripe/Apple, FCM), retention, or deletion.

### How to sort it out

Host HTML pages on your domain, for example:

- `https://onthebitefishing.com/privacy`
- `https://onthebitefishing.com/terms`

Cover collection, use, third-party sharing, retention, and how to request deletion. Use the **same URLs** in Settings, the subscribe screen, and App Store Connect. Confirm they load in Safari without a login.

---

## 3. Fix Info.plist permission strings

**Guidelines:** 5.1.1(ii) Permission, 5.1.1(iii) Data Minimization, 5.1.5 Location Services

Purpose strings must describe **current, actual** use. Paid functionality must not require granting extra data access. Apps should only request access relevant to core functionality.

### Current vs actual

| Key | Current string | What the app actually does | Fix |
|---|---|---|---|
| `NSCameraUsageDescription` | “Allow camera access to scan payment cards securely.” | Gallery only (profile/group). Camera is Stripe card scan. | Remove after dropping Stripe, or rewrite if you add a real camera feature. |
| `NSLocationWhenInUseUsageDescription` | “We request your location so we can enable location-based map features in a future update.” | Used **now**: map puck, catch grid, nearby zones. | Describe current use. Never say “future update.” |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | “We request your location so we can provide background weather alerts for your saved fishing zones.” | Only When In Use is requested. No location background mode. | Remove Always key, or actually request Always **and** add the location background mode if needed. |
| `NSPhotoLibraryUsageDescription` | “Allow photo library access to attach catch photos to your reports.” | Photos are for profile and group images, **not** catch reports. | Say: choose a profile or group photo from your library. |

### Suggested When In Use string

> On The Bite uses your location to show your position on the fishing map, snap catch reports to the correct Gulf zone, and load nearby bite activity.

Keep the existing fallback that still works if the user declines (5.1.1(iv)) — that part is already good. Location is requested in `login_controller.dart` after login via `LocationPermissionService.requestLocationWhenInUse()`. Code never requests Always.

### File

`ios/Runner/Info.plist`

---

## 4. Add user-generated content safety (Guideline 1.2)

Apps with user-generated content or social networking services **must** include:

1. A method for filtering objectionable material from being posted.
2. A mechanism to report offensive content and timely responses to concerns.
3. The ability to block abusive users from the service.
4. Published contact information so users can easily reach you.

### What this app has

The app is a social fishing network:

- Public catch reports
- Group chat (`GroupDetailsChatTab` / `MessageServiceController`)
- Group photos
- Profile photos

There is **no** `report`, `block`, or content-filter flow in Dart. `confirmReport` / `rejectReport` are bite-confirmation votes, not moderation. Group chat only supports reply and delete-own-message.

### How to sort it out

- Add **Report** on reports, messages, groups, and profiles.
- Add **Block user**, and hide blocked users’ content.
- Filter obvious slurs/spam before post (client + server).
- Publish a support email that actually opens.
- In App Review Notes, describe moderation SLAs and that a human reviews reports.

---

## 5. Scrub incomplete / placeholder content (2.1, 2.3.1)

Guideline 2.1: submissions should be final versions. Placeholder text, empty websites, and other temporary content should be scrubbed. Guideline 2.3.1: don’t include hidden, dormant, or undocumented features; don’t promote content the app does not actually offer.

### Must remove

| Item | File | Why |
|---|---|---|
| Subscription row “Future Premium Features” | `lib/features/profile_and_setting/controller/subscription_plan_controller.dart` | Selling content that does not exist. |
| `loadMockData()` seeding fake zone activity (Tuna, Marlin, 24 reports) before the API returns | `lib/features/map/controller/map_screen_controller.dart` (`onInit` always calls it) | Reviewers can treat that as fake or incomplete data (also 1.1.6 False information). |
| Hardcoded weather copy such as “Ideal conditions for offshore fishing with moderate seas and favorable winds” | `lib/features/report_main/summary/widgets/weather_tab_widget.dart` | Must be driven by live data. |
| Mapbox offline storage showing a mocked `85` MB used | `lib/core/services/mapbox_offline_service.dart` | Fake storage meter. |

### Reviewer access (2.1)

The whole product is behind login (`SplashScreenController` → onboarding/login if no token).

- Provide a **full-access demo account** in App Review Information.
- Keep the backend up during review.
- Note Gulf of Mexico coverage so a reviewer outside that region is not stuck on empty maps.
- Do not submit with TestFlight-only or unfinished flows. Guideline 2.2: betas belong in TestFlight, not the App Store.

---

## 6. Privacy manifest, Apple token revoke, support

### PrivacyInfo.xcprivacy

No app-level privacy manifest was found (`**/PrivacyInfo.xcprivacy` = 0 files).

Required Reason APIs used here include:

- UserDefaults (`shared_preferences`)
- File timestamps (`path_provider` / sqflite)
- Disk space

Missing or incomplete manifests are rejected at upload (ITMS-91053 / ITMS-91061) or in review.

**Fix:** Add `ios/Runner/PrivacyInfo.xcprivacy`, declare collected types and API reasons, and keep Firebase / Mapbox / Stripe (until removed) packages on versions that ship signed manifests.

### Sign in with Apple account deletion — Guideline 5.1.1(v)

Settings has Delete Account, which is required if the app supports account creation.

Apple also requires apps that use Sign in with Apple to **revoke the user’s Apple token via Apple’s REST API** when the account is deleted.

Today `_deleteAccount()` in `settings_screen_controller.dart` only hits `DELETE /user/delete` and clears local storage. It does **not**:

- Call Apple’s token revoke API
- Delete the Firebase Auth user

**Fix:** Wire revoke on the backend during delete, then sign out / delete the Firebase user.

### Guideline 1.5 — Developer Information

People need to know how to reach you. Failure to include accurate, up-to-date contact information can cause rejection.

`lib/features/profile_and_setting/presentation/screen/help_and_support_screen.dart` shows:

- Name: Payton Pieper
- Address: 5992 Alder Ave Pensacola FL 32526
- Email: `admin@onthebitefishing.com`

…as **plain text**. The email is not a `mailto:` link.

**Fix:** Make the email a `mailto:` link, and put a working Support URL (not a dead page or Google Slide) in App Store Connect.

---

## Already aligned

| Guideline | Status |
|---|---|
| 4.8 Sign in with Apple | Offered next to Google on login and create-account, with entitlements in `RunnerRelease.entitlements`. |
| 5.1.1(v) Delete account UI | Present under Settings with confirmation. Still needs Apple token revoke. |
| ATS / HTTPS | Production API is `https://onthebitefishing.com/api/v1`. No `NSAllowsArbitraryLoads`. |
| Location decline fallback | Falls back to a default Gulf zone instead of hard-blocking the app (5.1.1(iv)). |

---

## Additional notes (lower risk, still worth fixing)

### Hardcoded third-party API key — 1.6 Data Security

`lib/core/utils/constants/api_constants.dart` embeds a StormGlass API key in the client binary. That key can be extracted and abused. Move it server-side. Also confirm StormGlass’s terms allow this use (5.2.2 Third-Party Sites/Services).

### Mapbox token in source

`lib/core/utils/mapbox_config.dart` has a default public Mapbox access token. Restrict the token by URL/bundle in the Mapbox dashboard.

### `SystemUiMode.immersiveSticky` — 2.5.9 / Human Interface Guidelines

`lib/main.dart` hides the status bar and home indicator for the whole app. Apple sometimes rejects this for non-game/media apps because it alters standard system UI. Prefer `SystemUiMode.edgeToEdge` or overlay style unless you have a strong reason.

### Identity tokens logged in debug prints — 1.6 / 5.1.2

`apple_login_controller.dart` prints `idToken` and user email/name. Strip token logging from release builds.

### Subscription legal copy after switching to IAP

Once on StoreKit, Guideline 3.1.2(c) and Apple Pay-style recurring disclosure (4.9, if used) require, before subscribe:

- Length of the renewal term and that it continues until canceled
- What is provided during each period
- Actual charges
- How to cancel

StoreKit’s system sheet covers part of this; you still need in-app links to Privacy Policy and Terms, and a Restore button.

### App Privacy labels in App Store Connect

Review reconciles Nutrition Labels with what the binary actually does (location, photos, contact info, identifiers, purchases, crash data via Firebase, etc.). A mismatch is a 5.1.1 rejection even if the binary is otherwise fine. Declare everything Firebase, Mapbox, and your API collect.

### Age rating (2.3.6)

UGC (chat, photos, public reports) typically requires an honest age rating (often 12+). Do not rate 4+ if users can post unrestricted text and images.

---

## Resubmit order

1. Swap Stripe → Apple IAP on iOS and remove the Stripe paywall copy.
2. Publish real privacy/terms URLs.
3. Correct Info.plist strings and drop unused Always/Camera keys.
4. Ship report/block/filter for UGC.
5. Remove mock/future content; add `PrivacyInfo.xcprivacy` and Apple token revoke.
6. In Review Notes: demo login, IAP product IDs, why location is used, and how moderation works.

If Apple cited a different guideline in the rejection email, match that letter first — but Stripe for Pro is the issue most likely to fail review on a first look at this binary.

---

## Apple guideline references used

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Review — common issues](https://developer.apple.com/distribute/app-review/)
- [Requesting permission / purpose strings](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy/requesting_access_to_protected_resources)
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [Sign in with Apple — revoke tokens](https://developer.apple.com/documentation/sign_in_with_apple/revoke_tokens)
- [In-app purchase](https://developer.apple.com/in-app-purchase/)
- [Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/)

# 🚀 TestFlight Automated Deployment Setup Guide

This guide explains how to set up and run automated TestFlight deployments for **paytonpieper** (`com.onthebite.app.ios`) using **Fastlane** and **GitHub Actions**.

---

## 📋 Required GitHub Repository Secrets

Go to your GitHub repository: **Settings ➔ Secrets and variables ➔ Actions ➔ New repository secret**, and add the following 7 secrets:

| Secret Name | Description | Example / Format |
| :--- | :--- | :--- |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect API | `2X99A4XYZ` |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect API | `69a6de82-5011-47e3-e053-5b8c7c11a4d1` |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Full text content of the `.p8` API key file | `-----BEGIN PRIVATE KEY-----\nMIGTAgEAMBMG...` |
| `APPLE_TEAM_ID` | Apple Developer Team ID | `ABC123XYZ` |
| `BUILD_CERTIFICATE_BASE64` | Base64 encoded string of iOS Distribution `.p12` cert | Output of `base64 -i cert.p12` |
| `P12_PASSWORD` | Password used when exporting `.p12` certificate | Your password (or blank if no password) |
| `PROVISIONING_PROFILE_BASE64` | Base64 encoded string of `.mobileprovision` file | Output of `base64 -i profile.mobileprovision` |

---

## 🔑 Step-by-Step Credentials Generation

### Step 1: Create App Store Connect API Key
1. Log into [App Store Connect](https://appstoreconnect.apple.com/).
2. Go to **Users and Access ➔ Integrations ➔ App Store Connect API**.
3. Click **Generate API Key** (or the **+** button).
4. Name: `GitHub Actions CI/CD`, Access Role: **App Manager** or **Admin**.
5. Copy the **Issuer ID** and **Key ID**.
6. Download the private key file (`AuthKey_XXXXXX.p8`).
7. Open `AuthKey_XXXXXX.p8` in a text editor and copy the entire content into `APP_STORE_CONNECT_API_KEY_CONTENT`.

---

### Step 2: Export Distribution Certificate (`.p12`) & Convert to Base64
1. Open **Keychain Access** on your Mac.
2. Select **login** keychain ➔ **My Certificates**.
3. Find your **Apple Distribution Certificate** (or *iPhone Distribution*).
4. Right-click ➔ **Export "Apple Distribution: ..."**.
5. Save as `distribution.p12` and set a password.
6. Open your Mac Terminal and run:
   ```bash
   base64 -i distribution.p12 -o cert_base64.txt
   ```
7. Copy the contents of `cert_base64.txt` and save as secret `BUILD_CERTIFICATE_BASE64`.
8. Save the password as secret `P12_PASSWORD`.

---

### Step 3: Download Provisioning Profile & Convert to Base64
1. Go to [Apple Developer Portal ➔ Profiles](https://developer.apple.com/account/resources/profiles/list).
2. Download your **App Store Distribution Provisioning Profile** for `com.onthebite.app.ios` (e.g. `onthebite_appstore.mobileprovision`).
3. In Mac Terminal, run:
   ```bash
   base64 -i onthebite_appstore.mobileprovision -o profile_base64.txt
   ```
4. Copy the contents of `profile_base64.txt` and save as secret `PROVISIONING_PROFILE_BASE64`.

---

## 🛠️ Local Testing (Optional)

To test Fastlane locally on your Mac:

```bash
# 1. Install dependencies
cd ios
bundle install

# 2. Export environment variables in terminal
export APP_STORE_CONNECT_API_KEY_ID="YOUR_KEY_ID"
export APP_STORE_CONNECT_ISSUER_ID="YOUR_ISSUER_ID"
export APP_STORE_CONNECT_API_KEY_CONTENT="$(cat /path/to/AuthKey.p8)"

# 3. Run fastlane lane
bundle exec fastlane beta
```

---

## 🚀 Running on GitHub Actions

Once you push code to GitHub with secrets configured:
1. Every push to the **`main`** branch will automatically trigger `.github/workflows/deploy_testflight.yml`.
2. You can also trigger it manually from **GitHub ➔ Actions ➔ Deploy to TestFlight ➔ Run workflow**.

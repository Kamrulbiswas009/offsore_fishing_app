# PaytonPieper

A new Flutter project using GetX and Dio.

## 🧠 Last AI Session State
- **Phase**: 1
- **Task**: Fixed compilation errors in `app_routes.dart` (mapped missing screens to their correct class names). Finalized App Logic and API Implementation Plan based on exact GetX routing architecture.

## 🚧 Pending Tasks

### Step 1: Core App Initialization (Route: `/splashScreen1`)
- [ ] **Dio Client & Services**: Initialize `Dio` Singleton, `NetworkCaller`, and Interceptors.
- [ ] **Splash Data**: Validate cached Token from local storage. Fetch App Configurations (dynamic dropdown lists, map configs).

### Step 2: Authentication Flow (Routes: `/loginScreen`, `/createAccountScreen`, etc.)
- [ ] **Auth APIs**: Implement Login, Registration, Forgot Password, and OTP Verification APIs.
- [ ] **Session Storage**: Save Auth Token securely and navigate to `/homeMainScreen`.

### Step 3: Main Dashboard Setup (Route: `/homeMainScreen`)
- [ ] **Base Container**: Initialize the `IndexedStack` that manages the 4 core tabs (Map, Summary, Groups, Profile).

### Step 4: Map Tab Data (Route: `/zone_map_screen` - Nav Tab 0)
- [ ] **Zone Map API**: Fetch map markers, defined zones, and recent global/local catch locations.

### Step 5: Summary Tab Data (Route: `/summary-details` - Nav Tab 1)
- [ ] **Reports Feed API**: Fetch the main feed of `FishingReport`s. Implement active filtering by species, depth, technique, time, and type.
- [ ] **Summary Dashboard API**: Fetch user's `activityData` (BarChart data), catch counts, and personal stats.
- [ ] **Weather API**: Fetch current/forecast weather, wind, and tide data.

### Step 6: Groups Tab Data (Route: `/groupMainScreen` - Nav Tab 2)
- [ ] **Group List API**: Fetch the user's joined groups and suggested public groups.

### Step 7: Profile Tab Data (Route: `/profileMainScreen` - Nav Tab 3)
- [ ] **Profile API**: Fetch user profile details, total stats, and active subscription plan.

### Step 8: Submitting a Report (Routes: `/reportCatchScreen` -> `/reportCatch2Screen` -> `/submitReportScreen`)
- [ ] **Pre-fetch Catch Data**: Fetch dynamic species lists, techniques, and bait options for Step 1 & 2.
- [ ] **Submit API (`VisibilitySharingDialog`)**: Implement Multipart form-data submission for the new catch report (including images, location, and visibility settings).
- [ ] **Offline Sync API (`/offlineReportScreen`)**: Push cached offline reports when the connection is restored.

### Step 9: Content Details & Interactions (Routes: `/report-details`, `/groupDetailsScreen`, `/notificationScreen`)
- [ ] **Report Details API**: Fetch deep details for a single report, load comments, and submit 'Confirm Bite' (likes).
- [ ] **Group Details API**: Fetch group members, group-specific feed, and implement WebSocket/API for Group Chat.
- [ ] **Notifications API**: Fetch notification list and mark as read.

## ✅ Completed
- Deep-analyzed existing frontend codebase.
- Mapped all `GetPage` routes in `app_routes.dart` and fixed missing/incorrect class bindings.
- Fully mapped the App Logic and Data Flow to the user journey.
- Created and finalized the Step-by-Step API Implementation Roadmap.

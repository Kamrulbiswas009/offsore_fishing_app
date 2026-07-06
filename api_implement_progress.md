# API Implementation Progress: Offline-First Data Sync Mechanism

This document details the completed implementation of the offline-first data sync mechanism for catch report submissions.

---

## 1. System Overview

Anglers offshore often lack internet access. To prevent data loss, the application implements a robust **Offline-First Synchronization Flow**:
- **Online**: Sends reports directly to the backend API (`http://172.252.13.68:8000/api/v1/reports`) in real-time.
- **Offline / Failure Fallback**: Automatically saves submissions locally in an SQLite database with a "pending sync" status, then redirects the user to the offline feed.
- **Automatic Recovery**: Listens to connectivity changes reactively. When the device transitions from offline to online, a background sync is automatically triggered to upload queued reports in the correct order (FIFO).

---

## 2. Component Implementation Details

### Core Sync Handler
* **File**: `lib/core/services/sync_service.dart`
* **Responsibilities**:
  - Initializes SQLite database with a `pending_reports` table.
  - **True Internet Verification**: Performs a lightweight socket connection request directly to the API endpoint server (`172.252.13.68:8000`) and falls back to resolving `example.com` to confirm actual internet access.
  - Exposes reactive GetX states: `isOnline`, `pendingCount`, and `isSyncing`.
  - Listen to network status changes and triggers FIFO queue synchronization on reconnect.
  - Periodic retry timer (every 5 minutes) and launch synchronization.
  - **FIFO Sync & Exception Handling**: Syncs reports in sequential ID order, deletes from SQLite upon success, and proceeds to subsequent items on individual failures.

### Controllers & Screens
* **`ReportCatchController`** (`lib/features/report_main/report_catch/controller/report_catch_step1_screen.dart`):
  - Changed the default detected grid to `"GOM-2824"` (a valid database zone ID).
* **`ReportCatchStep1Screen`** (`lib/features/report_main/report_catch/screen/report_catch_screen.dart`):
  - Wrapped `_buildSyncStatusBar` with GetX `Obx` to display network and pending counts reactively.
* **`ReportCatch2Screen`** (`lib/features/report_main/report_catch2/screen/report_catch2_screen.dart`):
  - Wrapped `_buildSyncStatus` with GetX `Obx` to display network status and pending sync tags reactively.
* **`ReportCatch2Controller`** (`lib/features/report_main/report_catch2/controller/report_catch2_controller.dart`):
  - Formats user input into the backend POST JSON schema.
  - Generates client-side UUID v4 strings for `frontendReportId` to prevent duplicate submissions.
  - Normalizes mock zone selections to valid backend zone formats.
  - Implemented method-specific bait mappers (e.g., mapping `"Artificial Lure"` to `"VERTICAL_JIG"` when the method is `"JIGGING"`, and to `"SKIRTED_LURE"` for `"TROLLING"`) to satisfy backend enum pairs constraints.
* **`VisibilitySharingController`** (`lib/features/submit_report/controller/submit_report_controller.dart`):
  - Prompts a progress overlay, calls the POST API online, prints formatted logs using `AppLoggerHelper`, and falls back to SQLite queueing if offline or if the API returns a validation error.
  - Re-mapped mock groups to use valid UUID strings (`a0613eb0-3ca8-4522-9080-a83571dd7d81` etc.) instead of integers to pass UUID checks.
* **`OfflineReportsTabController`** (`lib/features/report_main/offline_report/controller/offline_report_controller.dart`):
  - Binds reactive variables directly to `SyncService`.
  - Queries local pending SQLite rows, converts them to `OfflineReportModel`, and lists them at the top of "My Reports".
* **`ReportSuccessController`** (`lib/features/success_submit_report/controller/success_controller.dart`):
  - Dynamically extracts and displays species, zone, and sharing info from parameters.

---

## 3. Submission Flow Walkthrough

### Scenario A: Device is Online (Real-time Submission)
1. User selects a grid in Step 1 (defaults to `"GOM-2824"`).
2. User inputs catch details in Step 2, and taps **Submit Report**.
3. Since the device is online, it prompts the **Visibility & Sharing** dialog.
4. User selects sharing visibility and taps **Submit Report**.
5. The application triggers `Get.showOverlay` with a loading indicator and POSTs the JSON payload directly to:
   `http://172.252.13.68:8000/api/v1/reports`
6. Upon a successful response, the console prints:
   `AppLoggerHelper.info("Report submitted online successfully. Response: ...")`
7. The app navigates to the **Success Screen** and shows the dynamically populated report summary.

### Scenario B: Device is Offline (Local Queue & Sync)
1. User inputs details and taps **Submit**.
2. If offline, the application bypasses the sharing dialog and saves the report locally in SQLite with a `PENDING` queue status and an ISO timestamp in `capturedOfflineAt`.
3. Displays a snackbar notification: *"No connection. Your report is saved locally..."*.
4. Navigates to **Offline Reports Screen** where the pending sync card dynamically displays:
   `1 pending reports in queue`
   And the local report shows up at the top of the **My Reports** list.
5. Once network connectivity is restored:
   - The connectivity listener detects the transition.
   - Triggers `triggerBackgroundSync()`.
   - Sends the report to the API backend in order.
   - Deletes the synced items from SQLite to clear the local queue.

---

## 4. Region & Zone Reports Feed Integration
* **API Endpoint**: `GET /api/v1/zones/reports?regionCode=GOM&scope=region`
* **Controller**: `SummaryController` (`lib/features/report_main/summary/controller/summary_details_controller.dart`)
* **Widget**: `ReportTabWidget` (`lib/features/report_main/summary/widgets/report_tab_widget.dart`)
* **Functionality**:
  - Dynamically fetches catch reports in the specified region on screen initialization.
  - Fixed a core issue in `NetworkCaller.getRequest` where passing a null token sent `'Authorization': 'null'`, resulting in request authentication failures on the server.
  - Configured a developer Bearer token fallback to ensure successful API requests during local/test setups when not logged in.
  - Client-side filters the reports list based on the active zone (`selectedZone.value?.name`) if we are viewing a specific zone page, restricting reports to only the selected zone.
  - Automatically maps response fields (including nested lists like `species` and complex objects like `user` and `biteConfirmations`) into native `FishingReport` model structures.
  - Formats `catchTimestamp` into an interactive relative "time ago" string.
  - Reverse-maps backend enums for fishing techniques and bait types to user-friendly titles.
  - Moves the pattern indicator widget inside the reactive `Obx()` list builder to dynamically display the number of reports matching the current zone (e.g., `"${list.length} Reports • Same Pattern"`).

---

## 5. Map Screen Dynamic Grid Integration
* **API Endpoint**: `GET /api/v1/zones/reports?regionCode=GOM&scope=region`
* **Controller**: `MapScreenController` (`lib/features/map/controller/map_screen_controller.dart`)
* **Widget**: `ZoneMapScreen` (`lib/features/map/screen/zone_map_screen.dart`)
* **Functionality**:
  - Calls the region reports API on startup to fetch all active catch reports.
  - Groups and aggregates reports dynamically by `zoneId`.
  - Calculates dynamic coordinates, species frequency (resolving `topSpecies`), average water depth (`avgDepth`), and report counts for each zone.
  - Dynamically sets the `ActivityLevel` (high, medium, low) per zone based on the count of active reports.
  - Populates Mapbox map grid cells reactively using a GetX worker listener (`ever`) in `ZoneMapScreen` to instantly trigger map redraws upon data fetch success.

---

## 6. Zone Summary Metrics & Graphics Integration
* **API Endpoint**: `GET /api/v1/zones/summary?regionCode=GOM&page=1&limit=20`
* **Controller**: `SummaryController` (`lib/features/report_main/summary/controller/summary_details_controller.dart`)
* **Widget**: `SummaryTabWidget` (`lib/features/report_main/summary/widgets/summary_tab_widget.dart`)
* **Functionality**:
  - Fetches region summary on startup (and zone summary dynamically by appending `&zoneId=...` if `selectedZone` is set).
  - **Activity Overview**: Dynamically binds target stats like "LAST 24H", "SUCCESS" (Hit Rate), "HOT ZONE", and "GROUPS" (Networks) to the returned `activityOverview` fields.
  - **Pattern Intelligence**: Adds a text description paragraph displaying the AI `summaryText`, and parses common depth, bait, method, and strike column enums dynamically.
  - **Activity Timing**: Linked peak window, most effective technique, and populated timing `BarChart` with dynamic 24-hour histogram rod values.
  - **Top Species**: Generated ranked species widgets dynamically from the API results. Wrapped all ranked items in `Expanded` and bounded their texts using `maxLines: 1` and `TextOverflow.ellipsis` to make the layout fully responsive and prevent RenderFlex overflow.
  - **Species Distribution**: Built `PieChartSectionData` list and legends dynamically matching the color palette.

---

## 7. Real-Time Marine Weather & Forecast Integration
* **API Endpoints**: 
  - Weather: `GET https://api.stormglass.io/v2/weather/point`
* **Controller**: `SummaryController` (`lib/features/report_main/summary/controller/summary_details_controller.dart`)
* **Widget**: `WeatherTabWidget` (`lib/features/report_main/summary/widgets/weather_tab_widget.dart`)
* **Functionality**:
  - Dynamically fetches local marine weather using StormGlass API for the active zone's coordinate parameters (`latitude`/`longitude`), falling back to Gulf of Mexico (GOM) regional center coordinates (`28.375`, `-89.125`) if no zone is selected.
  - Queries wind speed, wind direction, wave height, air temperature, water temperature, and cloud cover.
  - **"Now" Tab Metrics**:
    - Displays dynamic wind speed (converted from m/s to mph) and cardinal wind directions (e.g. `NE`, `SW`).
    - Displays dynamic wave height (converted from meters to feet), water temperatures, and cloud coverage rates.
    - Updates swell directions, air temperatures, and cloudiness markers in the Marine Details section reactively.
    - Implemented a loading indicator spinner inside `Obx` that runs while the StormGlass endpoint resolves.
  - **"Forecast" Tab Metrics**:
    - Dynamically generates the forecast select day tabs (e.g. `"Today"`, `"Mon 6"`, `"Tue 7"`) based on the sequential list of dates returned by the StormGlass forecast response payload.
    - Dynamically resolves hourly weather cards for `"Morning"` (9:00 AM), `"Afternoon"` (3:00 PM), and `"Evening"` (8:00 PM) for any selected forecast date, pulling actual wind speed, wave height, cloudiness percentage, and swell direction parameters from the API.



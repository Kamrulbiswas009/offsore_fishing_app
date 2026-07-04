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

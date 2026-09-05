# On The Bite – Phase 2 Technical Gap & Complexity Analysis
> **Document Version:** 1.0
> **Analyst:** Senior Flutter/GetX Technical Architect
> **PRD Source:** On_The_Bite_Phase_2_PRD_v1.6.md
> **Codebase:** `com.onthebite.app.ios` – Flutter/GetX monorepo
> **Analysis Date:** 2026-09-04

---

## 1. Executive Summary

The Phase 2 PRD introduces **8 major feature groups** decomposed into **38 discrete deliverables**. After mapping these against the existing production codebase, the complexity distribution is:

| Complexity | Count | Notes |
|---|---|---|
| HIGH | 14 | New backend schemas, new third-party APIs, architecture expansion |
| MEDIUM | 16 | New controllers/models, non-trivial UI, extends existing flows |
| LOW | 4 | Pure UI/UX tweaks reusing existing patterns |
| NEEDS CLARIFICATION | 4 | Ambiguous scope, cannot rate yet |

**Overall Timeline Impact Estimate:**
- LOW items: ~2–4 days each
- MEDIUM items: ~3–7 days each
- HIGH items: ~1–3 weeks each (with backend coordination)
- **Total rough estimate: 18–28 developer-weeks of Flutter work alone**, plus parallel backend effort for HIGH items.

> **CRITICAL DEPENDENCY:** The majority of HIGH-complexity items (Fish Box, T&C/Privacy versioning, Waypoints) require new backend API endpoints that do not yet exist in `https://onthebitefishing.com/api/v1`. These CANNOT be completed frontend-only.

---

## 2. Step 1 – Full Requirement Extraction & Categorization

### Feature 1 – Terms & Conditions

| # | Requirement | Category |
|---|---|---|
| 1.1 | Display T&C during account creation; require acceptance before app entry | (a) UI/UX change |
| 1.2 | Store: User ID, T&C version, acceptance timestamp | (e) Data model change |
| 1.3 | Version management: re-present on new version; block entry until accepted | (b) New feature |
| 1.4 | Retain full acceptance history | (e) Data model change |
| 1.5 | Error handling: block entry if acceptance cannot be saved | (a) UI/UX change |

### Feature 2 – Privacy Policy

| # | Requirement | Category |
|---|---|---|
| 2.1 | Display Privacy Policy during registration; require acknowledgment | (a) UI/UX change |
| 2.2 | Store: User ID, Policy version, acknowledgment timestamp | (e) Data model change |
| 2.3 | Version management: re-present on new policy version | (b) New feature |
| 2.4 | Retain previous acknowledgment history | (e) Data model change |
| 2.5 | Error handling: block app access until acknowledgment is recorded | (a) UI/UX change |

### Feature 3 – Release Notes / Changelog

| # | Requirement | Category |
|---|---|---|
| 3.1 | Auto-display changelog after app update; show once per version per user | (b) New feature |
| 3.2 | Changelog fields: Version, Release Date, New Features, Improvements, Bug Fixes | (e) Data model change |
| 3.3 | User can dismiss changelog; access from Settings | (a) UI/UX change |
| 3.4 | Admin CMS: create, edit, publish release notes without new app release | (c) Backend/API change |

### Feature 4 – Saved Waypoints + Coordinate Search + GPX Import/Export

| # | Requirement | Category |
|---|---|---|
| 4.1 | Create waypoint via long-press, GPS location, or manual coordinate entry | (b) New feature |
| 4.2 | Waypoint fields: Name (required), Description, Notes, Category, Icon, Color | (e) Data model change |
| 4.3 | Initial waypoint categories: Fishing Spot, Reef, Wreck, Rig, Artificial Reef, General | (e) Data model change |
| 4.4 | Coordinate search: support DD, DDM, DMS formats; center map; temp marker; option to save | (b) New feature |
| 4.5 | Waypoint management: Create, View, Edit, Delete, Search by name, Sort alpha/distance | (b) New feature |
| 4.6 | Waypoints are private to the owning user | (c) Backend/API change |
| 4.7 | GPX Import: parse .gpx, preview count, confirm, handle duplicates (Keep/Skip/Replace) | (b) New feature |
| 4.8 | GPX Export: single, multiple selected, or all waypoints; device native share | (b) New feature |
| 4.9 | Display saved waypoints as layer on Mapbox map | (a) UI/UX change |

### Feature 5 – Fish Box

| # | Requirement | Category |
|---|---|---|
| 5.1 | Fish Box creation: Trip Name (defaults to date), Trip Date, optional: Marina, Destination, Boat Name, Crew/Group, Notes | (b) New feature |
| 5.2 | Reuse existing report submission workflow; add Fish Box Trip ID to report payload | (e) Data model change |
| 5.3 | Map + FAB: present two options: "Add Report" vs "Create Fish Box" | (a) UI/UX change |
| 5.4 | Fish Box status lifecycle: Planned -> Active -> Completed / Cancelled | (b) New feature |
| 5.5 | Crew/Group selection in Fish Box: Select Existing, Create New (reuse Group creation), or Free-Form text | (b) New feature |
| 5.6 | Start Fish Box from Crew/Group UI | (a) UI/UX change |
| 5.7 | Auto-prompt "Add to active Fish Box?" when a report is created outside Fish Box while one is Active | (b) New feature |
| 5.8 | Quantity tracking: Total Caught, Kept, Released per species; validation: Kept + Released = Caught | (e) Data model change |
| 5.9 | Active Fish Box live summary: trip info, catch totals, species breakdown; real-time update | (b) New feature |
| 5.10 | Completed Fish Box summary: Trip Info, Catch Summary, Species Summary, Fishing Summary, Notes | (b) New feature |
| 5.11 | Fish Box notes: add/edit; plain text; max 5,000 characters | (a) UI/UX change |
| 5.12 | Fish Box history: search/filter by Trip Name, Species, Date/Range, Crew | (b) New feature |
| 5.13 | Crew Trip History: "Trips" tab in Group/Crew UI; list of completed Fish Boxes for that Group | (a) UI/UX change |
| 5.14 | Extensible data model for future fields: Fish Length, Weight, Personal Trophy, Crew Trophy (not exposed in Phase 2) | (e) Data model change |
| 5.15 | Architecture for future statistics: Crew stats, leaderboards, trophy case (not exposed in Phase 2) | (c) Backend/API change |

### Feature 6 – NOAA Bottom Topography Layer

| # | Requirement | Category |
|---|---|---|
| 6.1 | NOAA/NCEI bathymetric data overlay on existing Mapbox map | (d) Third-party integration |
| 6.2 | User can enable/disable layer | (a) UI/UX change |
| 6.3 | User can adjust layer transparency | (a) UI/UX change |
| 6.4 | Layer alignment while panning/zooming; works alongside Heat Map, Reports, Waypoints | (b) New feature |
| 6.5 | Error handling: fail gracefully if NOAA data fails; persist layer state between sessions | (b) New feature |

### Feature 7 – Artificial Reef Layer

| # | Requirement | Category |
|---|---|---|
| 7.1 | State/government-sourced artificial reef data overlay on Mapbox | (d) Third-party integration |
| 7.2 | Display: Reef Marker, Reef Name/Identifier, Coordinates, Water Depth | (b) New feature |
| 7.3 | Works simultaneously with other layers; fail gracefully | (b) New feature |
| 7.4 | Structured to add additional state datasets as coverage expands | (e) Data model change |

### Feature 8 – Layer Manager

| # | Requirement | Category |
|---|---|---|
| 8.1 | Layer Manager UI to independently show/hide: Fishing Reports, Heat Map, NOAA Bathymetry, Artificial Reefs, Saved Waypoints | (b) New feature |
| 8.2 | Persist layer selection state between sessions | (b) New feature |
| 8.3 | Only one Heat Map style active at a time | (a) UI/UX change |

---

## 3. Step 2 – Codebase Architecture Analysis

### 3.1 Architecture Pattern

The app follows a **Feature-First GetX architecture**:

```
lib/
├── core/
│   ├── bindings/       # Single ControllerBinder (all controllers lazy-registered at boot)
│   ├── common/         # Shared widgets, styles
│   ├── models/         # Shared models (species_node.dart, response_data.dart)
│   ├── services/       # Service layer (Firebase, networking, offline sync, mapbox offline)
│   └── utils/          # Constants, helpers, validators, logging
├── features/           # 13 feature modules (each has controller/ + screen/ or presentation/)
├── routes/             # AppRoutes (named route table)
└── utils/              # Zone calculator, misc
```

**GetX Pattern:** `GetxController` for state management, `RxVar.obs` for reactivity, `Get.lazyPut` with `fenix: true` in a single `ControllerBinder`. Services use `GetxService`. This is consistent and clean.

**Key service layer files:**
- `lib/core/services/network_caller.dart` – HTTP wrapper, token injection, caching
- `lib/core/services/sync_service.dart` – Connectivity monitoring, SQLite offline queue (sqflite), background sync
- `lib/core/services/storage_service.dart` – SharedPreferences abstraction (auth token, user data)
- `lib/core/services/offline_cache_service.dart` – Response caching
- `lib/core/services/mapbox_offline_service.dart` – Tile region/style pack for offline

**Backend:** `https://onthebitefishing.com/api/v1` (REST, bearer token auth). Real-time via Socket.IO (`socket_io_client`). No GraphQL.

### 3.2 Feature-to-PRD Mapping

| PRD Feature | Closest Existing Module | File Paths |
|---|---|---|
| T&C / Privacy | Authentication flow | `lib/features/authentication/controllers/`, `lib/features/authentication/presentation/` |
| Release Notes | Settings screen | `lib/features/profile_and_setting/controller/settings_screen_controller.dart` |
| Saved Waypoints | Map screen (Mapbox) | `lib/features/map/controller/map_screen_controller.dart`, `lib/features/map/screen/zone_map_screen.dart` |
| Coordinate Search | Map screen | `lib/features/map/screen/zone_map_screen.dart` |
| Fish Box | Report Submission + Groups | `lib/features/report_main/report_catch2/controller/report_catch2_controller.dart`, `lib/features/submit_report/controller/submit_report_controller.dart`, `lib/features/groups/` |
| Kept/Released Quantity | Report Catch2 controller | `lib/features/report_main/report_catch2/controller/report_catch2_controller.dart` (SpeciesEntry class, L15-47) |
| Map + FAB modification | Map screen | `lib/features/map/screen/zone_map_screen.dart` (_addButton() L850-872, _buildActionButtons() L763-786) |
| NOAA Bathymetry Layer | Mapbox map controller | `lib/features/map/controller/map_screen_controller.dart` (setupMapLayers()) |
| Artificial Reef Layer | Mapbox map controller | Same as above |
| Layer Manager | Map filter system | `lib/features/main_screen/controller/filter_controller.dart`, `lib/features/main_screen/widgets/filter_dialog.dart` |

### 3.3 Data Model Extensibility Assessment

| Model | Location | Extensibility |
|---|---|---|
| `SpeciesEntry` | `report_catch2_controller.dart` L15-47 | **Poor** – local Dart class, no `kept`/`released` fields. In-memory only, not serialized as standalone model. |
| `FishingReport` | `lib/features/report_main/report/model/report_model.dart` | **Poor** – display-only (7 string fields). No quantity split, no Fish Box ID, no quantity tracking. |
| `GroupListItem` / `GroupDetailModel` | `lib/features/groups/model/group_model.dart` | **Good** – already stores `groupId`. Fish Box can reference this directly. |
| Report API Payload (`buildReportPayload`) | `report_catch2_controller.dart` L598-671 | **Partial** – `groupId` already supported. Missing: `fishBoxId`, `quantityKept`, `quantityReleased` per species entry. |
| `MapZoneModel` | `lib/features/map/model/map_zone_model.dart` | **Limited** – zone data model only, not related to new layers. |
| SQLite schema (`SyncService`) | `lib/core/services/sync_service.dart` L49-85 | **Needs migration** – `pending_reports` table hardcoded at `version: 1`. No `onUpgrade` handler. |

### 3.4 Existing API/Backend Integration Pattern

All API calls go through `NetworkCaller` -> REST endpoints on `onthebitefishing.com/api/v1`.
No endpoint currently exists for: T&C/Privacy acceptance, Release notes, Waypoints (CRUD), Fish Box (CRUD), NOAA/bathymetry tile proxying, Reef data.

Real-time (Socket.IO) is used for group messaging (`MessageServiceController`). Fish Box "live summary" may also need this.

---

## 4. Step 3 – Full Gap & Complexity Mapping Table

| # | Requirement | Category | Affected Files/Modules | Complexity | Why Complex | Breaking Change? | New Dependencies |
|---|---|---|---|---|---|---|---|
| 1.1 | Display T&C during account creation; gate app entry | UI/UX | `authentication/presentation/`, `create_account_screen_controller.dart` | MEDIUM | New screen/widget; must intercept post-login routing in `SplashScreenController` | N | None |
| 1.2 | Store T&C acceptance (userId, version, timestamp) | Data Model | `storage_service.dart` (local flag) + backend API (new endpoint) | HIGH | No backend endpoint exists; needs new DB table and API route server-side | N | Backend API |
| 1.3 | T&C version management; re-gate on new version | New Feature | `splash_screen_controller.dart`, `authentication/controllers/` | HIGH | Version check at app startup; needs backend to serve current T&C version + content | N | Backend API |
| 1.4 | Retain T&C acceptance history | Data Model | Backend DB only | HIGH | Pure backend concern; API endpoint needed to write and read history | N | Backend API |
| 1.5 | Block entry if T&C acceptance cannot be saved | UI/UX | `splash_screen_controller.dart`, auth screens | LOW | Error dialog on API failure; reuses existing snackbar/dialog patterns | N | None |
| 2.1 | Display Privacy Policy during registration | UI/UX | `authentication/presentation/` (create account screen) | MEDIUM | New screen/modal; must be wired into existing create account flow | N | None |
| 2.2 | Store Privacy Policy acceptance (userId, version, timestamp) | Data Model | Same as 1.2 – backend new endpoint | HIGH | No backend endpoint; often bundled with T&C but requires separate tracking | N | Backend API |
| 2.3 | Privacy Policy version management | New Feature | `splash_screen_controller.dart`, auth flow | HIGH | Same challenge as 1.3; could be batched with T&C version check | N | Backend API |
| 2.4 | Retain Privacy Policy acceptance history | Data Model | Backend DB | HIGH | Backend-only; same pattern as 1.4 | N | Backend API |
| 2.5 | Block app if Privacy Policy not acknowledged | UI/UX | Splash/auth routing | LOW | Reuses pattern from 1.5 | N | None |
| 3.1 | Auto-display changelog once per version | New Feature | `splash_screen_controller.dart`, new `ChangelogController`, new screen | MEDIUM | Needs version comparison logic + "seen" flag stored per user/version. Backend serves content | N | Backend API |
| 3.2 | Changelog data model | Data Model | New model class + backend endpoint | MEDIUM | New model; no existing changelog infrastructure | N | None |
| 3.3 | User dismiss + access from Settings | UI/UX | `settings_screen_controller.dart`, new changelog screen | LOW | Settings screen already exists; add a new list tile + reuse changelog screen | N | None |
| 3.4 | Admin CMS for release notes (no app release required) | Backend/API | Backend only; no frontend required beyond the read API | HIGH | Content management system entirely on backend; frontend only reads JSON | N | Backend API |
| 4.1 | Create waypoint (long-press, GPS, manual entry) | New Feature | `map_screen_controller.dart`, `zone_map_screen.dart`, new `WaypointController` | HIGH | Map long-press not currently wired; coordinate parsing new; needs new backend CRUD endpoints | N | Backend API |
| 4.2 | Waypoint data model (Name, Desc, Notes, Category, Icon, Color) | Data Model | New `WaypointModel`; backend new table | HIGH | New backend schema; new Dart model; category/icon enum system | N | None |
| 4.3 | Waypoint categories (6 types) | Data Model | `WaypointModel`, UI dropdowns | LOW | Enum/list addition; follows existing method/bait enum patterns | N | None |
| 4.4 | Coordinate search: DD, DDM, DMS parsing; center map + temp marker | New Feature | `map_screen_controller.dart`, new search widget | MEDIUM | Coordinate format parsing is non-trivial; Mapbox centering reuses `easeTo()` pattern | N | `latlong2` (already installed) |
| 4.5 | Waypoint CRUD + list/search/sort | New Feature | New `WaypointController`, `WaypointListScreen`, `WaypointDetailScreen` | MEDIUM | Standard CRUD; reuses `NetworkCaller` pattern; sort by distance uses `geolocator` (already installed) | N | None |
| 4.6 | Waypoints private to owner | Backend/API | Backend auth/authorization on API | HIGH | Backend must scope waypoints by `userId` in token; frontend only sends auth token (already done) | N | Backend API |
| 4.7 | GPX Import: parse, preview, confirm, duplicate handling | New Feature | New `GpxImportController`, file picker integration | HIGH | GPX is XML; no XML parser in current `pubspec.yaml`; file picker integration new; duplicate detection logic | N | `xml` or `gpx` pub package; `file_picker` package |
| 4.8 | GPX Export: single/multi/all; native share | New Feature | New `GpxExportService`; `Share` dialog | MEDIUM | Generate GPX XML; use `Share.shareFiles()` from native share; `path_provider` already present | N | `share_plus` |
| 4.9 | Waypoints as map layer on Mapbox | UI/UX | `map_screen_controller.dart`, `zone_map_screen.dart` | MEDIUM | Mapbox GeoJSON source/symbol layer pattern already established in `setupMapLayers()`; add new source + symbol layer | N | None |
| 5.1 | Fish Box creation form (Trip Name, Date, optional fields) | New Feature | New `FishBoxController`, new `FishBoxCreateScreen` | MEDIUM | Standard form screen; follows existing screen patterns | N | None |
| 5.2 | Attach Fish Box Trip ID to report payload | Data Model | `report_catch2_controller.dart` (buildReportPayload() L598-671); `submit_report_controller.dart`; backend `POST /reports` | HIGH | Must add `fishBoxId` to payload; **backend must accept this new field on the reports endpoint** | YES – report API payload change | Backend API |
| 5.3 | Map + FAB: two-option menu (Add Report vs Create Fish Box) | UI/UX | `zone_map_screen.dart` (_addButton() L850-872, _buildActionButtons() L763-786) | LOW | Replace single FAB tap with bottom sheet showing two options; reuses existing Get.to pattern | N | None |
| 5.4 | Fish Box status lifecycle (Planned/Active/Completed/Cancelled) | New Feature | `FishBoxController`, backend `/fish-boxes` API | HIGH | New backend resource with status state machine; frontend status display + action buttons | N | Backend API |
| 5.5 | Crew selection in Fish Box (Existing Group, Create New, Free-Form) | New Feature | `FishBoxController`, `group_main_screen_controller.dart`, `create_group_screen_controller.dart` | MEDIUM | Reuse existing Group fetch (`featchGroupListApi`) and Create Group flow; group creation already works today | N | None |
| 5.6 | Start Fish Box from Crew/Group UI | UI/UX | `group_details_screen_controller.dart`, `lib/features/groups/presentation/` | MEDIUM | Add "Start Trip" button to Group detail screen; route to FishBox creation pre-populated with groupId | N | None |
| 5.7 | Auto-prompt "Add to active Fish Box?" when report created outside Fish Box | New Feature | `submit_report_controller.dart` (submitReport()), `FishBoxController` | MEDIUM | Check for active Fish Box in shared controller state; show dialog at report submission | N | None |
| 5.8 | Kept/Released quantity tracking + validation (Kept + Released = Caught) | Data Model | `report_catch2_controller.dart` (SpeciesEntry L15-47); report API payload; backend schema | HIGH | `SpeciesEntry` only has `quantity` (total); must add `quantityKept`+`quantityReleased`; validation logic; **backend must store these per-species** | YES – SpeciesEntry and API payload breaking change | Backend API |
| 5.9 | Active Fish Box live summary (real-time totals) | New Feature | New `FishBoxController`, new `ActiveFishBoxScreen`; possible Socket.IO integration | HIGH | Must aggregate reports linked to Fish Box in real-time; may require Socket.IO push or polling | N | None (Socket.IO already present) |
| 5.10 | Completed Fish Box detailed summary | New Feature | New `CompletedFishBoxScreen`, backend GET `/fish-boxes/:id` | MEDIUM | Read-only summary screen; data from backend; weather snapshot needed at completion time | N | None |
| 5.11 | Fish Box notes (add/edit; 5000 char max) | UI/UX | `FishBoxCreateScreen`, `ActiveFishBoxScreen` | LOW | TextFormField with maxLength; reuses existing notes pattern | N | None |
| 5.12 | Fish Box history with search/filter | New Feature | New `FishBoxHistoryController`, `FishBoxHistoryScreen` | MEDIUM | List + search/filter; reuses `NetworkCaller` pagination pattern | N | None |
| 5.13 | Crew Trip History tab in Group UI | UI/UX | `group_details_screen_controller.dart`, `lib/features/groups/presentation/` | MEDIUM | Add "Trips" tab to existing GroupDetailsScreen; fetch Fish Boxes filtered by groupId | N | None |
| 5.14 | Extensible data model for future fields (Length, Weight, Trophies) | Data Model | `SpeciesEntry`, backend report schema | MEDIUM | Add nullable fields to `SpeciesEntry` and report payload now even if not exposed in UI | N | None |
| 5.15 | Architecture for future stats/leaderboards/trophies | Backend/API | Backend schema design only | HIGH | Must design SQL schema so reports are queryable per Crew->Trip->Report->Species; never just aggregates | N | Backend coordination |
| 6.1 | NOAA/NCEI bathymetry as Mapbox overlay | Third-party | `map_screen_controller.dart`, new `NOAALayerService` | HIGH | NOAA serves WMS/WCS tiles; Mapbox SDK supports raster tile sources; must determine tile URL format, resolution, proxy strategy | N | NOAA public API (free; needs research) |
| 6.2 | Enable/disable NOAA layer | UI/UX | Layer Manager UI, `map_screen_controller.dart` | MEDIUM | Toggle Mapbox layer visibility; reuses `map.style.setLayerVisibility()` pattern | N | None |
| 6.3 | NOAA layer transparency adjustment | UI/UX | Layer Manager UI slider | MEDIUM | Mapbox layer opacity expression; slider widget | N | None |
| 6.4 | NOAA layer alignment, panning, zooming; coexistence with other layers | New Feature | `map_screen_controller.dart` | HIGH | Raster tile alignment at all zoom levels requires careful projection/tile URL handling; must not conflict with existing GeoJSON layers | N | None |
| 6.5 | NOAA error handling; persist layer state | New Feature | `storage_service.dart`, `map_screen_controller.dart` | MEDIUM | Try/catch on tile load; layer state persisted to SharedPreferences | N | None |
| 7.1 | State government artificial reef data overlay | Third-party | `map_screen_controller.dart`, new `ReefLayerService` | HIGH | Multiple state datasets (LA, AL, FL, TX, MS); likely GeoJSON or shapefile; need to identify exact state sources, formats, and hosting strategy | N | State gov APIs (TBD) |
| 7.2 | Reef marker display (Name, Coords, Depth) | New Feature | Mapbox SymbolLayer + popup; `ReefLayerService` | MEDIUM | SymbolLayer pattern already used for zone labels; popup on tap follows zone detail panel pattern | N | None |
| 7.3 | Reef layer: fail gracefully; coexist with other layers | New Feature | `map_screen_controller.dart` | MEDIUM | Error handling; layer ordering in Mapbox style stack | N | None |
| 7.4 | Structured for multi-state expansion | Data Model | `ReefLayerService`, data models | MEDIUM | Design state-keyed registry of data sources; extensible without code changes | N | None |
| 8.1 | Layer Manager UI for all map layers | New Feature | New `LayerManagerController`, new `LayerManagerSheet` widget | MEDIUM | Bottom sheet or slide-out panel; toggles for 5+ layers; reuses existing filter bottom sheet pattern from `filter_dialog.dart` | N | None |
| 8.2 | Persist layer selection state | New Feature | `storage_service.dart` (SharedPreferences) | LOW | JSON map of booleans to SharedPreferences; reads on map init | N | None |
| 8.3 | Only one Heat Map style active at a time | UI/UX | `LayerManagerController` | LOW | Radio button logic in UI; already conceptually similar to existing filter mutual exclusion | N | None |

---

## 5. Step 4 – Risk & Dependency Flags

### 5.1 Apple App Store Resubmission / Review Risk

| Risk Item | Reason | PRD Requirements |
|---|---|---|
| **Privacy Policy display during signup** | Apple requires a Privacy Policy linked in the App Store listing AND accessible within the app. Showing it interactively during signup may trigger reviewer scrutiny if the flow blocks sign-up. Must ensure "View complete policy" link is clearly accessible before user commits. | Feature 2 |
| **Location permission (waypoints)** | App already uses location (`permission_handler`, `geolocator`). If waypoint "Use GPS location" is added, verify current `ios/Runner/PrivacyInfo.xcprivacy` covers the GPX waypoint use case. Any new reason string = resubmission. | Feature 4.1 |
| **File access / document picker (GPX Import)** | Adding `file_picker` triggers new system permission prompt on iOS. Requires appropriate iCloud/Files entitlements. **App Store review guaranteed for new permission declarations.** | Feature 4.7 |
| **No IAP changes detected** | Fish Box, Waypoints, and Layer features do not mention IAP. If any premium gating is added, Stripe (already integrated) vs Apple IAP must be carefully handled (digital goods must use Apple IAP). | Future |
| **Existing Privacy Manifest** | Confirm `ios/Runner/PrivacyInfo.xcprivacy` covers `NSUserDefaults`, `FileTimestamp`, `DiskSpace`. Adding new packages (e.g., `xml`, `file_picker`) may require updating this manifest. | All new packages |

### 5.2 Changes Requiring Backend/API Coordination (Cannot be Done Frontend-Only)

| Item | What Backend Must Build |
|---|---|
| T&C Acceptance (1.2, 1.3, 1.4) | `POST /legal/terms/accept`, `GET /legal/terms/current`, `GET /legal/terms/history?userId=` |
| Privacy Policy Acceptance (2.2, 2.3, 2.4) | `POST /legal/privacy/accept`, `GET /legal/privacy/current` |
| Release Notes (3.1, 3.2, 3.4) | `GET /changelog`, Admin CRUD endpoints |
| Waypoints (4.1-4.6) | Full CRUD: `GET/POST /waypoints`, `GET/PUT/DELETE /waypoints/:id`. Scoped to authenticated user. |
| Fish Box (5.1-5.15) | `GET/POST /fish-boxes`, `GET/PUT/DELETE /fish-boxes/:id`, `POST /fish-boxes/:id/complete`, `POST /fish-boxes/:id/cancel`, `GET /fish-boxes?groupId=` |
| Report payload extension (5.2, 5.8) | `POST /reports` must accept new fields: `fishBoxId` (nullable), `quantityKept` (per species), `quantityReleased` (per species). **This is a breaking change to the existing reports endpoint schema.** |
| NOAA tile proxy (if needed) (6.1) | If NOAA WMS tiles need CORS headers or API key injection, backend proxy endpoint needed. |
| Artificial Reef data hosting (7.1) | Backend may need to serve normalized GeoJSON from multiple state sources. |

### 5.3 Regression Risk (Could Break Existing Features)

| Risk | Affected Existing Feature | Mitigation |
|---|---|---|
| **Adding `fishBoxId` + `quantityKept`/`quantityReleased` to `SpeciesEntry`** | Existing report submission flow (`ReportCatch2Controller` -> `buildReportPayload`). If backend rejects nullable fields for existing endpoint, report submission breaks. | Make nullable; ensure backend remains backward-compatible (ignores null fields) |
| **Modifying Map FAB (`_addButton()`) to show two options** | Current direct tap to `ReportCatchStep1Screen()`. Any re-routing errors will break report creation. | Feature-flag or additive approach (show sheet instead of replacing tap handler) |
| **Modifying `SplashScreenController` routing for T&C gate** | Current splash routing decides login/home navigation. Inserting a T&C check can break the existing flow. | Thoroughly test all auth states: first install, existing user no T&C, existing user T&C accepted |
| **Adding new SQLite schema migration in `SyncService`** | Current `version: 1` with no migration path. Existing offline-queued reports could be lost on schema update. | Implement proper `onUpgrade` migration with `ALTER TABLE` before schema change |
| **Adding new Mapbox layers** | If layer z-order (stacking) is not managed correctly, new layers could obscure existing zone grid layers. | Explicitly set `belowLayerId` when adding new layers to maintain correct z-order |
| **Group/Crew UI modifications** | Adding "Trips" tab to `GroupDetailsScreen` touches a large, complex screen (44KB controller). Risk of unintended UI regressions. | Add tab as purely additive; do not refactor existing tabs |

### 5.4 Third-Party API Quota / Cost Impact

| Service | Current Usage | Phase 2 Impact |
|---|---|---|
| **Mapbox** | Zone grid (GeoJSON), satellite imagery, offline tile packs | Adding NOAA raster layer + waypoint symbol layer + reef symbol layer = **more tile requests per session**. Estimate 20-40% increase in Mapbox API calls. |
| **Stormglass** (key in `api_constants.dart`) | Weather alerts (`weather_alert_service.dart`) | Fish Box "weather snapshot" at trip completion adds Stormglass calls. Stormglass free tier is 10 req/day — **likely quota impact if Fish Box usage is high**. Upgrade plan may be needed. |
| **NOAA/NCEI** | None currently | New. NOAA public APIs are free but may have rate limits on WMS/tile endpoints. Caching strategy essential. |
| **State Government Reef APIs** | None currently | New. Most state APIs are free but have undocumented rate limits. Data should be cached aggressively or pre-processed and hosted on own backend. |
| **Firebase** | Auth + FCM notifications | No change expected. |
| **Stripe** | Subscription payments | No change expected. |

---

## 6. Clarification Needed From Client

The following items are ambiguous or under-specified. **Send these questions to the client before scoping estimates.**

---

### Q1 – T&C and Privacy Policy: Where Is the Content Hosted?

**Context:** The PRD says users must be able to "view the complete Terms" and "view the complete policy." It does not specify where the legal text lives.

**Questions for client:**
1. Will the T&C and Privacy Policy text be stored in the backend database (fetched via API), or served from a static URL (e.g., a web page)?
2. If via API: who is responsible for creating the admin interface to update legal text?
3. What triggers a "new version" requiring re-acceptance — a version number increment, or any edit? Who controls version numbers?
4. Is there a legal requirement for the actual text to be rendered natively in-app, or is a WebView link to a hosted URL acceptable?

---

### Q2 – Fish Box: Backend Ownership and Real-Time Strategy

**Context:** Fish Box requires multiple new backend endpoints. The PRD says "live Fish Box summary" with totals that "update when new reports are added."

**Questions for client:**
1. Has the backend team been briefed on Phase 2? Are they resourced and ready to build Fish Box APIs in parallel with frontend work?
2. For the "live summary" — is real-time Socket.IO push acceptable (existing Socket.IO infrastructure is already in use for group chat), or is polling (e.g., every 30 seconds) acceptable?
3. The PRD says "Only one Fish Box may be Active per user at a time." Does the backend enforce this, or does the frontend enforce it? What happens if a user creates two via two devices?
4. Can a Fish Box be shared/viewed by other Crew members, or is it strictly private to the creating user? (The PRD says Fish Box is "private trip management" but Crew Trip History shows it to the group — clarify read permissions.)

---

### Q3 – NOAA Bottom Topography: Resolution, Tiling Strategy, and Coverage Area

**Context:** The PRD says "highest practical resolution available" and mentions NOAA NCEI, Coastal Relief Models, DEMs. NOAA provides multiple data products in different formats (WMS, WCS, downloadable grids) with varying resolutions.

**Questions for client:**
1. What is the specific geographic bounding box for "On The Bite coverage area"? (Currently the app is Gulf of Mexico centered at ~28.5N, -88.5W. Is this the full required extent?)
2. Is the client aware that high-resolution NOAA bathymetric data may require significant bandwidth? What is the acceptable minimum resolution (e.g., 3 arc-second vs. 1 arc-second)?
3. Does the client want the frontend to hit NOAA tile servers directly, or should the backend host/proxy the tile data? (Direct NOAA WMS can have latency issues.)
4. What is the expected performance requirement for layer load time on a typical LTE connection?

---

### Q4 – Artificial Reef Layer: State Source Selection and Data Freshness

**Context:** Gulf of Mexico states include Texas, Louisiana, Mississippi, Alabama, and Florida — each with its own reef database.

**Questions for client:**
1. Which specific states are in scope for Phase 2? (All five Gulf states, or a subset?)
2. Are the client or dev team aware of the current state of these datasets?
   - **Texas:** TPWD artificial reef data (available as shapefile/CSV)
   - **Louisiana:** LDWF reef data (available online)
   - **Alabama:** ADCNR reef coordinates (published as PDFs in some cases — not machine-readable)
   - **Florida:** FWC reef database (API available)
3. For states where data is only available as PDF or irregular formats, is the dev team authorized to manually digitize and host that data, or must it be strictly automated/official?
4. How frequently does reef data need to refresh? (Some state datasets update annually, others more frequently.)

---

## 7. Suggested Implementation Order

### Wave 1: Backend-Independent Items (Start immediately while backend builds new endpoints)

1. **[LOW] Layer Manager UI shell** (8.1-8.3) — Build the Layer Manager bottom sheet with toggle switches. Wire to existing Heat Map layer only first. Establishes architecture for all new layers.
2. **[LOW] Map + FAB two-option menu** (5.3) — Replace single FAB tap with bottom sheet. Purely additive. Zero regression risk.
3. **[LOW] Fish Box Notes UI** (5.11) — TextFormField; can be built as a standalone widget.
4. **[MEDIUM] Fish Box creation form** (5.1) — Build full Fish Box creation screen. Wire to mock data/local state only. Integrate with backend when API is ready.
5. **[MEDIUM] Crew selection in Fish Box** (5.5) — Reuse existing `featchGroupListApi`; works TODAY with no backend changes.
6. **[LOW] Persist layer selection state** (8.2) — SharedPreferences for layer toggles.

### Wave 2: Map Layers (Backend-Independent for Public Data)

7. **[HIGH] NOAA Bathymetry Layer** (6.1-6.5) — Research NOAA tile endpoint. Implement raster source in Mapbox. Add to Layer Manager.
8. **[HIGH] Artificial Reef Layer** (7.1-7.4) — Identify state data sources. Parse GeoJSON/CSV. Load as Mapbox SymbolLayer. Add to Layer Manager.
9. **[MEDIUM] Waypoint map layer** (4.9) — Mapbox SymbolLayer for waypoints; uses local/mock data first.

### Wave 3: Waypoints (requires backend waypoints API)

10. **[HIGH] Waypoint backend API integration** (4.1, 4.6) — Once backend `/waypoints` endpoints are ready.
11. **[MEDIUM] Waypoint CRUD screens** (4.5)
12. **[MEDIUM] Coordinate search** (4.4)
13. **[HIGH] GPX Import** (4.7) — Add `xml`/`gpx` package; build import wizard.
14. **[MEDIUM] GPX Export** (4.8) — Add `share_plus`; generate GPX XML.

### Wave 4: Fish Box Backend Integration (requires Fish Box API + report API changes)

> **CRITICAL: Coordinate with backend team on report payload changes BEFORE this wave.**

15. **[HIGH] Report payload extension** (5.2) — Add `fishBoxId` to `buildReportPayload()`.
16. **[HIGH] Kept/Released quantity in report flow** (5.8) — Modify `SpeciesEntry`, add UI fields, add validation.
17. **[HIGH] Fish Box status lifecycle** (5.4)
18. **[HIGH] Active Fish Box live summary** (5.9)
19. **[MEDIUM] Completed Fish Box summary screen** (5.10)
20. **[MEDIUM] Fish Box history** (5.12)
21. **[MEDIUM] Start Fish Box from Crew UI** (5.6) + **[MEDIUM] Crew Trip History tab** (5.13)
22. **[MEDIUM] Auto-prompt "Add to Fish Box?"** (5.7)

### Wave 5: Legal & Compliance (requires legal API + App Store review)

> **This wave requires App Store resubmission — plan review time (1-2 weeks Apple queue).**

23. **[HIGH] T&C display + acceptance** (1.1-1.5)
24. **[HIGH] Privacy Policy display + acknowledgment** (2.1-2.5)
25. **[MEDIUM] Release Notes / Changelog** (3.1-3.3)
26. **[HIGH] Release Notes admin/CMS** (3.4) — Backend only; ensure frontend read integration.

---

## 8. New Package Dependencies Required

| Package | Purpose | PRD Items | Risk Level |
|---|---|---|---|
| `xml` or `gpx` (pub.dev) | Parse .gpx XML files for import | 4.7 | Low – well-maintained packages |
| `file_picker` | Let user select .gpx file from device | 4.7 | **Medium – triggers iOS Files/iCloud permission; App Store review** |
| `share_plus` | Native share dialog for GPX export | 4.8 | Low |
| None (NOAA tiles) | NOAA WMS served as Mapbox `RasterTileSource` | 6.1-6.5 | Low (Mapbox SDK already supports this) |
| None (reef data) | GeoJSON from state sources loaded as `GeoJsonSource` | 7.1-7.4 | Low |

---

## 9. Codebase Quick Reference

| File | Purpose | Phase 2 Relevance |
|---|---|---|
| `lib/features/map/screen/zone_map_screen.dart` | Main map screen (1857 lines) | FAB modification, waypoint layer, reef layer, NOAA layer, Layer Manager |
| `lib/features/map/controller/map_screen_controller.dart` | Map state + Mapbox layer setup (1163 lines) | All new map layers, waypoint GeoJSON source |
| `lib/features/report_main/report_catch2/controller/report_catch2_controller.dart` | Report form state + payload builder (705 lines) | SpeciesEntry kept/released, buildReportPayload() + fishBoxId |
| `lib/features/submit_report/controller/submit_report_controller.dart` | Report submission to API | Fish Box auto-prompt, groupId pattern to extend |
| `lib/features/groups/controller/group_details_screen_controller.dart` | Group detail controller (44KB) | "Trips" tab, "Start Trip" button |
| `lib/features/groups/model/group_model.dart` | Group data models | Fish Box -> Group ID reference |
| `lib/core/services/sync_service.dart` | Offline queue + SQLite (637 lines) | Schema migration needed for new report fields |
| `lib/core/services/storage_service.dart` | SharedPreferences wrapper | Layer state persistence, version seen flags |
| `lib/core/utils/constants/api_constants.dart` | All API endpoint URLs | New endpoints for all Phase 2 features |
| `lib/core/bindings/controller_binder.dart` | GetX dependency injection | New controllers must be registered here |

---

*End of Analysis – On The Bite Phase 2 Technical Gap & Complexity Analysis*

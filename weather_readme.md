# Weather Zone Alerts — Feature Documentation

> **Feature**: #3 — Saved Zone Weather Alerts  
> **Status**: ✅ Implemented  
> **Last Updated**: 2026-07-17 (v2 — Map Panel + Weather Tab fully aligned)

---

## Overview

The **Saved Zone Weather Alerts** feature allows anglers to **watch specific fishing zones** and receive **smart notifications** when weather conditions (wave height, wind speed, water temperature) meaningfully change. Users can watch a zone directly from the **map zone panel** or from the **Weather tab** inside the zone summary screen. The system suppresses repetitive/unchanged alerts to prevent notification fatigue.

---

## User-Facing Acceptance Criteria

| # | Criterion | Status |
|:--|:---|:---:|
| 1 | Users can watch/save zones for weather monitoring | ✅ |
| 2 | Users can enable or disable weather alerts per zone | ✅ |
| 3 | System monitors weather thresholds for watched zones (wave height, wind, temp) | ✅ |
| 4 | Notification triggers only when conditions meaningfully improve or deteriorate | ✅ |
| 5 | Notification includes: zone name, key condition change, forecast timeframe | ✅ |
| 6 | Tapping notification opens the zone weather screen | ✅ |
| 7 | System suppresses excessive repeat alerts for unchanged conditions | ✅ |

---

## Architecture

### New Files

| File | Role |
|:---|:---|
| `lib/features/weather_alerts/model/watched_zone_model.dart` | `WatchedZoneConfig` data model + `ZoneAlertSnapshot` for suppression |
| `lib/core/services/weather_alert_service.dart` | `GetxService` singleton — polling, threshold checks, suppression, alert dispatch |
| `lib/features/weather_alerts/controller/weather_alert_controller.dart` | `GetxController` — bridges service to UI |
| `lib/features/weather_alerts/widgets/zone_watch_settings_sheet.dart` | Premium bottom sheet for configuring zone watch thresholds |
| `lib/features/weather_alerts/screen/watched_zones_screen.dart` | Full-screen list of all watched zones with management UI |

### Modified Files

| File | Change |
|:---|:---|
| `lib/core/services/storage_service.dart` | Added `watched_zones_json` and `weather_alert_cache_json` SharedPreferences keys |
| `lib/core/services/firebase/fcm_handler.dart` | Re-implemented with weather alert foreground routing and tap navigation |
| `lib/core/services/firebase/app_notification_initializer.dart` | Re-implemented to request FCM permissions and wire background handler |
| `lib/core/bindings/controller_binder.dart` | Registered `WeatherAlertService` (permanent) and `WeatherAlertController` (lazy) |
| `lib/main.dart` | Added `AppNotificationInitializer.init()` and `WeatherAlertService.startMonitoring()` |
| `lib/routes/app_routes.dart` | Added `/watchedZonesScreen` route |
| `lib/features/map/screen/zone_map_screen.dart` | Added Watch Zone banner + alert toggle inside zone detail panel CTA area |
| `lib/features/report_main/summary/widgets/weather_tab_widget.dart` | Added Watch Zone banner with alert on/off toggle at top of Weather tab |

---

## Data Model

### `WatchedZoneConfig`

```dart
class WatchedZoneConfig {
  final String zoneId;                  // e.g. "GOM-R74-C88"
  final String zoneName;                // human-readable display name
  final double lat, lng;                // StormGlass coordinates
  final bool alertsEnabled;             // master alert toggle
  final double waveHeightThresholdFt;   // default: 4.0 ft
  final double windSpeedThresholdMph;   // default: 20.0 mph
  final double waterTempChangeDeltaF;   // default: 5.0 °F
  final bool alertOnThunderstorm;       // default: true
  final bool alertOnRain;               // default: true
  final bool alertOnGoodSunny;           // default: true
}
```

Stored as JSON array in `SharedPreferences` key `watched_zones_json`.

### `ZoneAlertSnapshot`

```dart
class ZoneAlertSnapshot {
  final String conditionHash;   // bucketed condition hash (e.g. "w3:v4:ct" where ct is condition token)
  final DateTime lastAlertAt;   // UTC timestamp of last sent alert
}
```

Stored as JSON map `{zoneId: snapshot}` in `SharedPreferences` key `weather_alert_cache_json`.

---

## Alert Suppression Logic

```
// Build bucketed condition hash
waveBucket = floor(waveHeightFt / 1.0)    // 1-ft buckets
windBucket = floor(windSpeedMph / 5.0)    // 5-mph buckets
conditionSuffix = "t" (thunderstorm) / "r" (rain) / "s" (sunny) / "o" (ordinary)
currentHash = "w{waveBucket}:v{windBucket}:c{conditionSuffix}"

// Suppression rules
hashChanged     = currentHash != storedHash[zoneId]
cooldownPassed  = now - lastAlertAt >= 4 hours

// Only fire if BOTH are true
if (hashChanged && cooldownPassed):
    fire alert
    store currentHash + timestamp
else:
    suppress (silent update of hash if changed, no alert)
```

**Key properties:**
- **Minimum re-alert gap**: 4 hours per zone (regardless of condition changes)
- **Bucket granularity**: 1 ft wave, 5 mph wind — small fluctuations within a bucket are silently ignored
- **Condition detection**: Active weather patterns like thunderstorm, rain, and sunny days trigger alerts immediately if enabled and transitioned.
- **Threshold check**: Alert only fires if the observed value actually crosses the user-configured threshold or condition state toggles.

---

## Weather Polling

| Property | Value |
|:---|:---|
| **Interval** | Every 30 minutes |
| **Data Source** | StormGlass API (existing integration) |
| **Cache TTL** | 30 minutes (`alert_weather_{lat}_{lng}` cache key) |
| **Forced Refresh** | Yes — always fetches fresh data for alerts |
| **Entry Selected** | Closest hourly entry to current UTC time |

---

## Alert Notification Format

### In-App (Foreground) — GetX Snackbar

```
┌──────────────────────────────────────────────────────┐
│ 🔔  🌊 GOM-R74-C88                                   │
│      Wave height 5.2 ft, Wind 22 mph                 │
│      📅 This Morning                    [View Zone →] │
└──────────────────────────────────────────────────────┘
```

- Position: TOP
- Duration: 8 seconds
- Dismissible: Yes
- Tapping **View Zone →** constructs a `MapZoneModel` and navigates to `SummaryScreen` (which shows a back button since `isReportMainScreen` resolves to `false`).

### Toggle Alert Snackbar (Inline from banner tap)

```
┌──────────────────────────────────┐
│ 🔔 Alerts On                     │  ← teal background
│ You'll be notified on condition  │
│ changes in GOM-R74-C88.          │
└──────────────────────────────────┘
```

```
┌──────────────────────────────────┐
│ 🔕 Alerts Paused                 │  ← dark red background
│ Weather alerts paused for        │
│ GOM-R74-C88.                     │
└──────────────────────────────────┘
```

- Position: BOTTOM
- Duration: 3 seconds

### Push (Background) — FCM

FCM handles background delivery via `firebase_messaging`. On notification tap, it parses the zone information, constructs a `MapZoneModel`, and navigates to `SummaryScreen` with a visible back button:
- `data.type == "weather_alert"` → navigates to `SummaryScreen` with `liveZone` argument.

---

## User Interface

### 1. Watch Zone Banner — Map Zone Panel (`zone_map_screen.dart`)

Located **above the "View Full Details" button** in the zone detail bottom panel on the map.

| State | Bell Icon | Label | Badge | Single Tap | Long Press |
|:---|:---:|:---|:---:|:---|:---|
| **Not watched** | `notifications_none` grey | "Watch This Zone" | — | Opens `ZoneWatchSettingsSheet` | — |
| **Watching — Alerts On** | `notifications_active` teal | "Weather Alerts Active" | `On` (teal) | Pauses alerts instantly | Opens settings sheet to edit thresholds |
| **Watching — Alerts Paused** | `notifications_paused` orange | "Alerts Paused" | `Paused` (orange) | Re-enables alerts instantly | Opens settings sheet to edit thresholds |

> The banner animates between states with an elastic bell scale and color crossfade.

---

### 2. Watch Zone Banner — Weather Tab (`weather_tab_widget.dart`)

Located **at the very top** of the Weather tab on any zone summary screen. Identical 3-state UX to the map panel.

| State | Bell Icon | Label | Badge | Single Tap | Long Press |
|:---|:---:|:---|:---:|:---|:---|
| **Not watched** | `notifications_none` grey | "Watch This Zone" | — | Opens `ZoneWatchSettingsSheet` | — |
| **Alerts On** | `notifications_active` teal | "Weather Alerts Active" | `On` (teal) | Pauses alerts | Opens `WatchedZonesScreen` |
| **Alerts Paused** | `notifications_paused` orange | "Alerts Paused" | `Paused` (orange) | Re-enables alerts | Opens `WatchedZonesScreen` |

> Subtitle hint: `"Tap to pause  •  Hold to manage"` or `"Tap to re-enable  •  Hold to manage"`

Both banners share the **same `WeatherAlertController` singleton** — a watch action on the map panel is immediately reflected in the weather tab and vice versa.

---

### 3. Zone Watch Settings Sheet (Bottom Sheet)

Accessible when tapping the Watch Zone banner on an **unwatched** zone.

| Setting | Range | Default |
|:---|:---|:---|
| Weather Alerts toggle | On/Off | On |
| Wave Height Alert | 1–12 ft | 4 ft |
| Wind Speed Alert | 5–50 mph | 20 mph |
| Water Temp Change | 1–15 °F | 5 °F |
| Thunderstorm Alert | On/Off | On |
| Rain Alert | On/Off | On |
| Sunny Day / Good Alert | On/Off | On |

> **Precise Adjustment**: Each threshold slider is flanked by `-` (decrement) and `+` (increment) buttons, allowing the user to precisely step values by defined intervals (e.g. `0.5 ft` for waves, `2.5 mph` for wind) and inspect real-time updates.

Also accessible via **Edit Thresholds** in the Watched Zones screen (edit mode).

---

### 4. Watched Zones Screen (`/watchedZonesScreen`)

Full-screen management interface. Access via **long-press** on any Watch Zone banner (when zone is already watched).

Shows all watched zones as cards, each with:
- Per-zone enable/disable toggle
- Threshold pills (wave, wind, temp)
- Last alert timestamp ("2h ago", "Just now", etc.)
- **Edit Thresholds** → reopens settings sheet in edit mode
- **Remove** → confirmation dialog, removes zone from watch list

Empty state: illustration + "Browse Zones" CTA.

---

## User Flow Diagram

```
Map Zone Panel (tap zone)
  └─ Zone Detail Bottom Sheet
       ├─ [Watch Zone Banner]
       │    ├─ Not watched  → tap → ZoneWatchSettingsSheet (save → zone added)
       │    ├─ Alerts On    → tap → Pause alerts (snackbar confirmation)
       │    └─ Alerts Off   → tap → Re-enable alerts (snackbar confirmation)
       │
       └─ [View Full Details] → SummaryScreen
                                  └─ Weather Tab
                                       ├─ [Watch Zone Banner] (same 3-state, synced)
                                       │    ├─ tap  → toggle On/Off
       │                               └─ long press → WatchedZonesScreen
       │
       └─ WatchedZonesScreen (long press on either banner)
            ├─ Toggle per zone
            ├─ Edit Thresholds → ZoneWatchSettingsSheet (edit mode)
            └─ Remove Zone → dialog → removed
```

---

## Integration Points

### GetX Dependency Injection

```dart
// controller_binder.dart — registered in order:
Get.put(WeatherAlertService(), permanent: true);   // core singleton
Get.lazyPut<WeatherAlertController>(..., fenix: true);
```

### StorageService Keys

| Key | Type | Content |
|:---|:---|:---|
| `watched_zones_json` | `String` | JSON array of `WatchedZoneConfig` |
| `weather_alert_cache_json` | `String` | JSON map of `{zoneId: ZoneAlertSnapshot}` |

### FCM Notification Payload

```json
{
  "type": "weather_alert",
  "zoneId": "GOM-R74-C88",
  "zoneName": "GOM-R74-C88",
  "conditionChange": "Wave height 5.2 ft, Wind 22 mph",
  "forecastWindow": "This Morning"
}
```

---

## Testing Checklist

### Manual Verification

#### Map Panel flow
- [ ] Open any zone on the map → zone detail panel shows Watch Zone banner
- [ ] Tap banner (unwatched) → settings sheet opens with sliders
- [ ] Save thresholds → banner changes to "Weather Alerts Active" (teal `On` badge)
- [ ] Tap banner again → "Alerts Paused" state (orange badge), bottom snackbar fires
- [ ] Tap again → re-enabled (teal badge), snackbar confirms

#### Summary / Weather Tab flow
- [ ] Navigate to SummaryScreen from zone panel → Weather tab shows same watch state
- [ ] Tap banner (same toggle behaviour) → state stays in sync with map panel
- [ ] Long-press banner → opens WatchedZonesScreen

#### WatchedZonesScreen
- [ ] Toggle switch per card disables/enables alerts
- [ ] "Edit Thresholds" → settings sheet pre-filled with current values
- [ ] "Remove" → confirmation dialog → zone removed from list
- [ ] Empty state appears when all zones removed

#### Persistence
- [ ] Kill + restart app → watched zones and alert states restored

#### Alert suppression
- [ ] Set wave threshold to 0 ft → next poll cycle fires a TOP snackbar alert
- [ ] Two alerts within 4 hours for same zone → second is suppressed

### Alert Suppression Test (Dev)

```dart
// In WeatherAlertService, temporarily set:
static const Duration _cooldownDuration = Duration(seconds: 30);
// And set waveHeightThresholdFt = 0 on a watched zone.
// → alert fires within the next poll cycle (or immediately on addZone)
// → second alert within 30s is suppressed
```

---

## Known Limitations & Future Enhancements

| # | Limitation | Suggested Enhancement |
|:--|:---|:---|
| 1 | Background FCM payload not sent from backend (no server-side endpoint yet) | Backend sends FCM push with `weather_alert` type when threshold crossed |
| 2 | No rich push notification (image, expandable body) | Add `flutter_local_notifications` for rich format |
| 3 | Polling stops when app is fully killed | Use `WorkManager` (Android) / `background_fetch` (iOS) for true background polling |
| 4 | Single alert channel — no urgency grouping | Add severity levels (WARNING / CRITICAL) with distinct sounds |
| 5 | Water temp delta uses a best-effort last-known cache | Store last temp reading directly inside `ZoneAlertSnapshot` |
| 6 | Alert toggle (On/Pause) is instant but doesn't show a dedicated confirm screen | A quick action dialog could let user "Snooze for 24h" instead of fully pausing |

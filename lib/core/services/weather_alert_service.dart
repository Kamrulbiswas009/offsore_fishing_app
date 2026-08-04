import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/features/weather_alerts/model/watched_zone_model.dart';
import 'package:paytonpieper/routes/app_routes.dart';

/// [WeatherAlertService] is a persistent [GetxService] singleton that:
///   1. Loads watched zones from [StorageService].
///   2. Polls StormGlass every [_pollInterval] minutes in the background.
///   3. Compares current vs. last-notified conditions using a bucketed hash.
///   4. Fires an in-app GetX snackbar alert only when conditions change
///      meaningfully and a minimum [_cooldownDuration] has elapsed.
///   5. Suppresses identical/unchanged conditions to avoid alert fatigue.
class WeatherAlertService extends GetxService {
  static const Duration _pollInterval = Duration(minutes: 30);
  static const Duration _cooldownDuration = Duration(hours: 4);

  /// All currently watched zone configs.
  final RxList<WatchedZoneConfig> watchedZones = <WatchedZoneConfig>[].obs;

  /// Map of zoneId → last alert snapshot (for suppression logic).
  final Map<String, ZoneAlertSnapshot> _alertCache = {};

  Timer? _pollTimer;
  bool _isPolling = false;

  // ────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────────────────────

  /// Start the background monitoring timer.
  void startMonitoring() {
    _pollTimer?.cancel();
    // Run an immediate check, then schedule recurring polls.
    _runAllChecks();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _runAllChecks());
    AppLoggerHelper.info('[WeatherAlerts] Monitoring started (interval: $_pollInterval)');
  }

  /// Stop the background monitoring timer.
  void stopMonitoring() {
    _pollTimer?.cancel();
    _pollTimer = null;
    AppLoggerHelper.info('[WeatherAlerts] Monitoring stopped');
  }

  /// Add a zone to the watch list and persist it.
  Future<void> addZone(WatchedZoneConfig zone) async {
    watchedZones.removeWhere((z) => z.zoneId == zone.zoneId);
    watchedZones.add(zone);
    await _persist();
    // Run an immediate check for the newly watched zone.
    if (zone.alertsEnabled) _checkZone(zone);
  }

  /// Remove a zone from the watch list and persist.
  Future<void> removeZone(String zoneId) async {
    watchedZones.removeWhere((z) => z.zoneId == zoneId);
    _alertCache.remove(zoneId);
    await _persist();
    await _persistAlertCache();
  }

  /// Update (replace) a zone config and persist.
  Future<void> updateZone(WatchedZoneConfig zone) async {
    final idx = watchedZones.indexWhere((z) => z.zoneId == zone.zoneId);
    if (idx != -1) {
      watchedZones[idx] = zone;
    } else {
      watchedZones.add(zone);
    }
    await _persist();
  }

  /// Toggle alerts enabled/disabled for a zone.
  Future<void> toggleAlerts(String zoneId, bool enabled) async {
    final idx = watchedZones.indexWhere((z) => z.zoneId == zoneId);
    if (idx == -1) return;
    watchedZones[idx] = watchedZones[idx].copyWith(alertsEnabled: enabled);
    await _persist();
  }

  /// Whether a zone is currently being watched.
  bool isWatched(String zoneId) =>
      watchedZones.any((z) => z.zoneId == zoneId);

  /// Returns the config for a zone, or null.
  WatchedZoneConfig? configFor(String zoneId) {
    try {
      return watchedZones.firstWhere((z) => z.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  /// Last alert snapshot for a zone (used by the UI to show "last alerted").
  ZoneAlertSnapshot? lastSnapshotFor(String zoneId) =>
      _alertCache[zoneId];

  // ────────────────────────────────────────────────────────────────────────────
  // Monitoring loop
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _runAllChecks() async {
    if (_isPolling) return;
    _isPolling = true;
    try {
      for (final zone in List<WatchedZoneConfig>.from(watchedZones)) {
        if (zone.alertsEnabled) {
          await _checkZone(zone);
        }
      }
    } catch (e) {
      AppLoggerHelper.error('[WeatherAlerts] Poll loop error', e);
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _checkZone(WatchedZoneConfig zone) async {
    try {
      final entry = await _fetchCurrentWeather(zone.lat, zone.lng);
      if (entry == null) return;

      final waveHeight = _extractSg(entry['waveHeight']);
      final windSpeed = _extractSg(entry['windSpeed']);
      final waterTemp = _extractSg(entry['waterTemperature']);
      final cloudCover = _extractSg(entry['cloudCover']);
      final precipitation = _extractSg(entry['precipitation']) ?? 0.0;

      if (waveHeight == null && windSpeed == null) return;

      // Convert to imperial
      final waveHeightFt = (waveHeight ?? 0) * 3.281;
      final windSpeedMph = (windSpeed ?? 0) * 2.237;
      final waterTempF = waterTemp != null ? (waterTemp * 9 / 5) + 32 : null;

      // Evaluate weather conditions
      final isThunderstorm = precipitation >= 2.5 && windSpeedMph >= 25.0;
      final isRain = precipitation >= 0.5 && !isThunderstorm;
      final isGoodSunny = cloudCover != null && cloudCover < 30.0 && precipitation < 0.1;

      // Determine condition token
      String conditionSuffix = 'o'; // ordinary
      if (isThunderstorm) {
        conditionSuffix = 't';
      } else if (isRain) {
        conditionSuffix = 'r';
      } else if (isGoodSunny) {
        conditionSuffix = 's';
      }

      // Build a bucketed hash (1ft wave buckets, 5mph wind buckets, condition token)
      final waveBucket = (waveHeightFt / 1.0).floor();
      final windBucket = (windSpeedMph / 5.0).floor();
      final currentHash = 'w$waveBucket:v$windBucket:c$conditionSuffix';

      final prevSnapshot = _alertCache[zone.zoneId];
      final now = DateTime.now().toUtc();

      // Suppression: skip if hash unchanged OR cooldown not elapsed
      final hashChanged = prevSnapshot == null || prevSnapshot.conditionHash != currentHash;
      final cooldownPassed = prevSnapshot == null ||
          now.difference(prevSnapshot.lastAlertAt) >= _cooldownDuration;

      if (!hashChanged || !cooldownPassed) {
        AppLoggerHelper.info(
          '[WeatherAlerts] ${zone.zoneId}: suppressed (hashChanged=$hashChanged, cooldownPassed=$cooldownPassed)',
        );
        return;
      }

      // Determine what changed meaningfully
      final List<String> changes = [];
      if (waveHeightFt < zone.waveHeightThresholdFt) {
        changes.add('Wave height ${waveHeightFt.toStringAsFixed(1)} ft');
      }
      if (windSpeedMph < zone.windSpeedThresholdMph) {
        changes.add('Wind ${windSpeedMph.toStringAsFixed(0)} mph');
      }
      if (waterTempF != null && prevSnapshot != null) {
        // Compare temp delta using cached hash prefix (best-effort)
        final tempChange = (waterTempF - _lastKnownTempF(zone.zoneId)).abs();
        if (tempChange >= zone.waterTempChangeDeltaF) {
          changes.add('Water temp ${waterTempF.toStringAsFixed(0)}°F');
        }
      }

      // Specific weather condition alerts
      if (zone.alertOnThunderstorm && isThunderstorm) {
        changes.add('⛈️ Thunderstorm Warning');
      } else if (zone.alertOnRain && isRain) {
        changes.add('🌧️ Rain Alert');
      } else if (zone.alertOnGoodSunny && isGoodSunny) {
        changes.add('☀️ Sunny / Good weather');
      }

      if (changes.isEmpty && prevSnapshot != null) {
        // Nothing crossed threshold — but hash changed, meaning small delta.
        // Still update hash silently (no alert).
        _alertCache[zone.zoneId] = ZoneAlertSnapshot(
          conditionHash: currentHash,
          lastAlertAt: prevSnapshot.lastAlertAt, // keep original alert time
        );
        await _persistAlertCache();
        return;
      }

      // Fire the alert
      final conditionText = changes.isNotEmpty
          ? changes.join(', ')
          : 'Conditions changed';
      final forecastWindow = _forecastWindowLabel();

      _dispatchAlert(
        zone: zone,
        conditionText: conditionText,
        forecastWindow: forecastWindow,
        waveHeightFt: waveHeightFt,
        windSpeedMph: windSpeedMph,
        waterTempF: waterTempF,
      );

      // Save snapshot
      _alertCache[zone.zoneId] = ZoneAlertSnapshot(
        conditionHash: currentHash,
        lastAlertAt: now,
      );
      _lastKnownTempCache[zone.zoneId] = waterTempF ?? 0;
      await _persistAlertCache();

      AppLoggerHelper.info(
        '[WeatherAlerts] Alert fired for ${zone.zoneName}: $conditionText',
      );
    } catch (e) {
      AppLoggerHelper.error('[WeatherAlerts] checkZone error (${zone.zoneId})', e);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Alert dispatch
  // ────────────────────────────────────────────────────────────────────────────

  final Map<String, double> _lastKnownTempCache = {};

  double _lastKnownTempF(String zoneId) =>
      _lastKnownTempCache[zoneId] ?? 78.0;

  void _dispatchAlert({
    required WatchedZoneConfig zone,
    required String conditionText,
    required String forecastWindow,
    double? waveHeightFt,
    double? windSpeedMph,
    double? waterTempF,
  }) {
    // Foreground in-app alert via GetX snackbar
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE25301).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFFE25301),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌊 ${zone.zoneName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  conditionText,
                  style: const TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '📅 $forecastWindow',
            style: const TextStyle(
              color: Color(0xFF8B95A5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Get.closeCurrentSnackbar();
                  final liveZone = MapZoneModel(
                    id: zone.zoneId,
                    name: zone.zoneName,
                    location: LatLng(zone.lat, zone.lng),
                    count: 0,
                    level: ActivityLevel.medium,
                  );
                  Get.toNamed(
                    AppRoute.summaryScreen,
                    arguments: liveZone,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF117A88),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View Zone →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0D2B43),
      borderColor: const Color(0xFF117A88),
      borderWidth: 1,
      borderRadius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 8),
      isDismissible: true,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Weather data fetching
  // ────────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchCurrentWeather(double lat, double lng) async {
    try {
      final network = NetworkCaller();
      final url =
          'https://api.stormglass.io/v2/weather/point?lat=$lat&lng=$lng&params=windSpeed,waveHeight,waterTemperature,cloudCover,precipitation';
      final cacheKey = 'alert_weather_${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}';

      final response = await network.cachedGetRequest(
        url,
        token: ApiConstants.stormGlassApiKey,
        cacheKey: cacheKey,
        ttlMinutes: 30,
        forceRefresh: true,
      );

      if (!response.isSuccess) return null;

      final data = response.responseData;
      if (data is! Map<String, dynamic>) return null;

      final hours = data['hours'] as List?;
      if (hours == null || hours.isEmpty) return null;

      // Find the entry closest to now
      final now = DateTime.now().toUtc();
      Map<String, dynamic>? best;
      double minDiff = double.infinity;
      for (final item in hours) {
        if (item is! Map<String, dynamic>) continue;
        final timeStr = item['time'] as String?;
        if (timeStr == null) continue;
        try {
          final dt = DateTime.parse(timeStr).toUtc();
          final diff = dt.difference(now).inMinutes.abs().toDouble();
          if (diff < minDiff) {
            minDiff = diff;
            best = item;
          }
        } catch (_) {}
      }
      return best;
    } catch (e) {
      AppLoggerHelper.error('[WeatherAlerts] fetchCurrentWeather error', e);
      return null;
    }
  }

  double? _extractSg(dynamic field) {
    if (field == null) return null;
    if (field is num) return field.toDouble();
    if (field is Map) {
      for (final val in field.values) {
        if (val is num) return val.toDouble();
      }
    }
    return null;
  }

  String _forecastWindowLabel() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'This Morning';
    if (hour < 17) return 'This Afternoon';
    return 'This Evening';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Persistence
  // ────────────────────────────────────────────────────────────────────────────

  void _loadFromStorage() {
    // Load watched zones
    final zonesJson = StorageService.getWatchedZonesJson();
    if (zonesJson != null && zonesJson.isNotEmpty) {
      watchedZones.assignAll(WatchedZoneConfig.decodeList(zonesJson));
    }

    // Load alert snapshot cache
    final cacheJson = StorageService.getWeatherAlertCacheJson();
    if (cacheJson != null && cacheJson.isNotEmpty) {
      _alertCache.addAll(ZoneAlertSnapshot.decodeMap(cacheJson));
    }

    AppLoggerHelper.info(
      '[WeatherAlerts] Loaded ${watchedZones.length} watched zone(s), ${_alertCache.length} cached snapshot(s)',
    );
  }

  Future<void> _persist() async {
    await StorageService.saveWatchedZonesJson(
      WatchedZoneConfig.encodeList(watchedZones),
    );
  }

  Future<void> _persistAlertCache() async {
    await StorageService.saveWeatherAlertCacheJson(
      ZoneAlertSnapshot.encodeMap(_alertCache),
    );
  }
}

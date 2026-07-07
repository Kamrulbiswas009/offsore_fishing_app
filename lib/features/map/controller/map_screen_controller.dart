import 'dart:convert';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../model/map_zone_model.dart';
import '../utils/zone_grid_helper.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';

// ── Source / Layer IDs ────────────────────────────────────────────────────
const kGridCellSourceId  = 'zone-grid-cell-source';   // polygons (fill + line)
const kGridLabelSourceId = 'zone-grid-label-source';  // points (symbols)

const kGridFillLayerId  = 'zone-grid-fill-layer';
const kGridLineLayerId  = 'zone-grid-line-layer';
const kGridLabelLayerId = 'zone-grid-label-layer';

class MapScreenController extends GetxController {
  // Map centre – Gulf of Mexico offshore
  final LatLng mapCenter = const LatLng(28.5, -88.5);

  // Grid origin pinned to real-world SW corner
  static const LatLng gridOrigin = LatLng(20.0, -100.0);

  late final ZoneGridHelper gridHelper;

  // cell-id → {level, count}
  final Map<String, Map<String, dynamic>> activityMap = {};

  // ── Reactive state ────────────────────────────────────────────────────
  var activeZones  = <MapZoneModel>[].obs;
  var selectedZone = Rxn<MapZoneModel>();
  var selectedCellId = RxnString();

  var isLoading = false.obs;
  bool isInitialFetch = true;

  bool _isFetching = false;
  double? _pendingSouth;
  double? _pendingNorth;
  double? _pendingWest;
  double? _pendingEast;
  mapbox.MapboxMap? _pendingMap;

  // ── Debounce Workers & State ──────────────────────────────────────────
  final _cameraBounds = Rxn<Map<String, dynamic>>();
  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    gridHelper = const ZoneGridHelper(
      origin: gridOrigin,
      cellMiles: 8.0,
    );
    loadMockData();


    _debounceWorker = debounce(
      _cameraBounds,
      (Map<String, dynamic>? bounds) {
        if (bounds != null) {
          fetchZones(
            south: bounds['south'],
            north: bounds['north'],
            west: bounds['west'],
            east: bounds['east'],
            map: bounds['map'],
          );
        }
      },
      time: const Duration(seconds: 10), 
    );

    fetchZones(
      south: 28.0,
      north: 29.0,
      west: -90.0,
      east: -88.0,
    );
  }

  @override
  void onClose() {

    _debounceWorker?.dispose();
    super.onClose();
  }

  // ── Map layer setup (called once after style loads) ───────────────────

  Future<void> setupMapLayers(mapbox.MapboxMap map) async {
    // Disable built-in ornaments
    await map.compass.updateSettings(mapbox.CompassSettings(enabled: false));
    await map.scaleBar.updateSettings(mapbox.ScaleBarSettings(enabled: false));

    // Empty sources – populated on first camera-change update
    final emptyCollection = jsonEncode({'type': 'FeatureCollection', 'features': <dynamic>[]});

    await map.style.addSource(
      mapbox.GeoJsonSource(id: kGridCellSourceId,  data: emptyCollection),
    );
    await map.style.addSource(
      mapbox.GeoJsonSource(id: kGridLabelSourceId, data: emptyCollection),
    );

    // FillLayer – data-driven colour per activityLevel
    await map.style.addLayer(
      mapbox.FillLayer(
        id:       kGridFillLayerId,
        sourceId: kGridCellSourceId,
        fillColorExpression: [
          'match',
          ['get', 'activityLevel'],
          'high',   'rgba(226, 83, 1, 0.55)',
          'medium', 'rgba(0, 184, 217, 0.40)',
          'low',    'rgba(28, 44, 58, 0.45)',
          'rgba(0, 0, 0, 0)',         // empty → transparent
        ],
        fillOpacity: 1.0,
        fillOutlineColor: 0x00000000, // outline via LineLayer
      ),
    );

    // LineLayer – draws the cyan grid partition lines
    await map.style.addLayer(
      mapbox.LineLayer(
        id:          kGridLineLayerId,
        sourceId:    kGridCellSourceId,
        lineColor:   0x2800F0FF,   // semi-transparent cyan
        lineWidth:   0.8,
        lineOpacity: 1.0,
      ),
    );

    // SymbolLayer – white count labels centred in active cells
    await map.style.addLayer(
      mapbox.SymbolLayer(
        id:                 kGridLabelLayerId,
        sourceId:           kGridLabelSourceId,
        textFieldExpression: ['get', 'label'],
        textSize:            16.0,
        textColor:           0xFFFFFFFF,
        textHaloColor:       0xCC000000,
        textHaloWidth:       1.2,
        textFont:            ['DIN Pro Bold', 'Arial Unicode MS Bold'],
        textAllowOverlap:    true,
        iconAllowOverlap:    true,
      ),
    );

    // Mock user location source and layers (pulsing blue dot/puck at Gulf of Mexico)
    await map.style.addSource(
      mapbox.GeoJsonSource(
        id: 'mock-user-location-source',
        data: jsonEncode({
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'properties': <String, dynamic>{},
              'geometry': {
                'type': 'Point',
                'coordinates': [-88.5, 28.5]
              }
            }
          ]
        }),
      ),
    );

    // Outer cyan ring for the location puck
    await map.style.addLayer(
      mapbox.CircleLayer(
        id: 'mock-user-location-puck-outer',
        sourceId: 'mock-user-location-source',
        circleColor: 0xFF00F0FF,
        circleOpacity: 0.25,
        circleRadius: 18.0,
      ),
    );

    // Inner solid cyan dot with white stroke
    await map.style.addLayer(
      mapbox.CircleLayer(
        id: 'mock-user-location-puck-inner',
        sourceId: 'mock-user-location-source',
        circleColor: 0xFF00F0FF,
        circleRadius: 8.0,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 2.0,
      ),
    );
  }

  // ── Dynamic grid refresh (called on every camera change) ──────────────

  /// Rebuilds GeoJSON sources to cover the current [sw]→[ne] viewport.
  Future<void> updateGridForBounds(
    mapbox.MapboxMap map,
    LatLng sw,
    LatLng ne,
  ) async {
    if (isInitialFetch) {
      isInitialFetch = false;
      await fetchZones(
        south: 28.0,
        north: 29.0,
        west: -90.0,
        east: -88.0,
        map: map,
      );
    } else {
      // সরাসরি API কল না করে reactive variable-এ ডাটা পুশ করা হচ্ছে।
      // এর ফলে ম্যাপ যতবারই স্ক্রোল হোক, ১০ সেকেন্ডের ডিবান্সার এটিকে লক করে রাখবে।
      _cameraBounds.value = {
        'south': sw.latitude,
        'north': ne.latitude,
        'west': sw.longitude,
        'east': ne.longitude,
        'map': map,
      };
    }
  }

  // ── Tap → zone lookup ─────────────────────────────────────────────────

  MapZoneModel? zoneForCoordinate(double lat, double lng) {
    for (final z in activeZones) {
      if (z.south != null && z.north != null && z.west != null && z.east != null) {
        if (lat >= z.south! && lat <= z.north! && lng >= z.west! && lng <= z.east!) {
          selectedCellId.value = z.id;
          return z;
        }
      } else {
        // Fallback to grid helper if bounds are not available
        final cell = gridHelper.cellForCoordinate(LatLng(lat, lng));
        if (cell == null) continue;
        final zCell = gridHelper.cellForCoordinate(z.location);
        if (zCell?.id == cell.id) {
          selectedCellId.value = cell.id;
          return z;
        }
      }
    }
    return null;
  }

  void selectZone(MapZoneModel zone) => selectedZone.value = zone;
  void deselectZone() => selectedZone.value = null;

  // ── Mock data ─────────────────────────────────────────────────────────

  void loadMockData() {
    activeZones.assignAll([
      const MapZoneModel(
        id: '1', name: 'GOM-12',
        location: LatLng(28.55, -88.45),
        count: 12, level: ActivityLevel.high,
        reports: 24, lastUpdated: '6 hours ago',
        activityScore: 0.92, topSpecies: 'Tuna', avgDepth: '120 ft',
        trend: TrendDirection.rising,
      ),
      const MapZoneModel(
        id: '2', name: 'GOM-8',
        location: LatLng(28.62, -88.60),
        count: 8, level: ActivityLevel.high,
        reports: 17, lastUpdated: '2 hours ago',
        activityScore: 0.78, topSpecies: 'Marlin', avgDepth: '95 ft',
        trend: TrendDirection.stable,
      ),
      const MapZoneModel(
        id: '3', name: 'GOM-3',
        location: LatLng(28.48, -88.52),
        count: 3, level: ActivityLevel.medium,
        reports: 6, lastUpdated: '1 day ago',
        activityScore: 0.35, topSpecies: 'Snapper', avgDepth: '60 ft',
        trend: TrendDirection.falling,
      ),
      const MapZoneModel(
        id: '5', name: 'GOM-1',
        location: LatLng(28.45, -88.42),
        count: 1, level: ActivityLevel.low,
        reports: 3, lastUpdated: '5 hours ago',
        activityScore: 0.15, topSpecies: 'Wahoo', avgDepth: '140 ft',
        trend: TrendDirection.stable,
      ),
      const MapZoneModel(
        id: '6', name: 'GOM-7',
        location: LatLng(28.50, -88.30),
        count: 7, level: ActivityLevel.medium,
        reports: 14, lastUpdated: '30 min ago',
        activityScore: 0.68, topSpecies: 'Mahi', avgDepth: '110 ft',
        trend: TrendDirection.rising,
      ),
      const MapZoneModel(
        id: '7', name: 'GOM-4',
        location: LatLng(28.53, -88.22),
        count: 4, level: ActivityLevel.medium,
        reports: 9, lastUpdated: '4 hours ago',
        activityScore: 0.44, topSpecies: 'Sailfish', avgDepth: '200 ft',
        trend: TrendDirection.falling,
      ),
    ]);

    // Build activity map keyed by cell id
    activityMap.clear();
    for (final z in activeZones) {
      final cell = gridHelper.cellForCoordinate(z.location);
      if (cell == null) continue;
      activityMap[cell.id] = {'level': z.level.name, 'count': z.count};
    }
  }

  // ── Zones API Fetch ───────────────────────────────────────────────────

  Future<void> fetchZones({
    double south = 28.0,
    double north = 29.0,
    double west = -90.0,
    double east = -88.0,
    mapbox.MapboxMap? map,
  }) async {
    if (_isFetching) {
      _pendingSouth = south;
      _pendingNorth = north;
      _pendingWest = west;
      _pendingEast = east;
      _pendingMap = map;
      return;
    }

    _isFetching = true;
    isLoading.value = true;
    try {
      final network = NetworkCaller();
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final url = ApiConstants.getZonesApi(
        south: south,
        north: north,
        west: west,
        east: east,
      );

      final response = await network.getRequest(
        url,
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          "Successfully fetched zones. API: $url, Response: ${response.responseData}",
        );
        final data = response.responseData['data'] as List?;
        if (data != null) {
          final List<MapZoneModel> zonesList = [];
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final zoneId = item['zoneId'] ?? '';
              final displayName = item['displayName'] ?? zoneId;
              final centerLat = (item['centerLat'] as num?)?.toDouble() ?? 0.0;
              final centerLng = (item['centerLng'] as num?)?.toDouble() ?? 0.0;
              
              final boundsMap = item['bounds'] as Map<String, dynamic>?;
              final zNorth = (boundsMap?['north'] as num?)?.toDouble();
              final zSouth = (boundsMap?['south'] as num?)?.toDouble();
              final zEast = (boundsMap?['east'] as num?)?.toDouble();
              final zWest = (boundsMap?['west'] as num?)?.toDouble();

              final activityScore = (item['activityScore'] as num?)?.toDouble() ?? 0.0;
              final trendDirectionStr = item['trendDirection'] as String? ?? 'STABLE';
              final reportCount = (item['reportCount'] as num?)?.toInt() ?? 0;

              // Map trend direction
              TrendDirection trend = TrendDirection.stable;
              if (trendDirectionStr == 'RISING') {
                trend = TrendDirection.rising;
              } else if (trendDirectionStr == 'FALLING') {
                trend = TrendDirection.falling;
              }

              // Determine activity level
              ActivityLevel level = ActivityLevel.low;
              if (reportCount >= 5 || activityScore >= 70.0) {
                level = ActivityLevel.high;
              } else if (reportCount >= 1 || activityScore >= 30.0) {
                level = ActivityLevel.medium;
              }

              zonesList.add(MapZoneModel(
                id: zoneId,
                name: displayName,
                location: LatLng(centerLat, centerLng),
                count: reportCount,
                level: level,
                reports: reportCount,
                activityScore: activityScore > 1.0 ? activityScore / 100.0 : activityScore,
                trend: trend,
                north: zNorth,
                south: zSouth,
                east: zEast,
                west: zWest,
              ));
            }
          }

          activeZones.assignAll(zonesList);

          // If map is provided, update the grid layers immediately
          if (map != null) {
            await _updateMapGridLayers(map, zonesList);
          }
        }
      } else {
        AppLoggerHelper.error(
          "Failed to fetch zones. StatusCode: ${response.statusCode}, Error: ${response.errorMessage}",
        );
      }
    } catch (e, stack) {
      AppLoggerHelper.error("Exception fetching zones: $e", stack);
    } finally {
      _isFetching = false;
      if (_pendingSouth != null) {
        final pSouth = _pendingSouth!;
        final pNorth = _pendingNorth!;
        final pWest = _pendingWest!;
        final pEast = _pendingEast!;
        final pMap = _pendingMap;

        _pendingSouth = null;
        _pendingNorth = null;
        _pendingWest = null;
        _pendingEast = null;
        _pendingMap = null;

        await fetchZones(
          south: pSouth,
          north: pNorth,
          west: pWest,
          east: pEast,
          map: pMap,
        );
      } else {
        isLoading.value = false;
      }
    }
  }

  Map<String, dynamic> buildCellGeoJsonFromZones(List<MapZoneModel> zones) {
    final features = zones.map((z) {
      final swLng = z.west ?? (z.location.longitude - 0.125);
      final swLat = z.south ?? (z.location.latitude - 0.125);
      final neLng = z.east ?? (z.location.longitude + 0.125);
      final neLat = z.north ?? (z.location.latitude + 0.125);

      return {
        'type': 'Feature',
        'id': z.id,
        'geometry': {
          'type': 'Polygon',
          'coordinates': [
            [
              [swLng, swLat],
              [neLng, swLat],
              [neLng, neLat],
              [swLng, neLat],
              [swLng, swLat],
            ]
          ],
        },
        'properties': {
          'id': z.id,
          'activityLevel': z.level.name,
          'reportCount': z.count,
          'label': z.count > 0 ? z.count.toString() : '',
        },
      };
    }).toList();

    return {
      'type': 'FeatureCollection',
      'features': features,
    };
  }

  Map<String, dynamic> buildLabelGeoJsonFromZones(List<MapZoneModel> zones) {
    final features = <Map<String, dynamic>>[];
    for (final z in zones) {
      if (z.count == 0) continue;
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [z.location.longitude, z.location.latitude],
        },
        'properties': {
          'label': z.count.toString(),
          'activityLevel': z.level.name,
        },
      });
    }
    return {
      'type': 'FeatureCollection',
      'features': features,
    };
  }

  Future<void> _updateMapGridLayers(mapbox.MapboxMap map, List<MapZoneModel> zones) async {
    try {
      final cellJson = buildCellGeoJsonFromZones(zones);
      final labelJson = buildLabelGeoJsonFromZones(zones);

      final cellSrc =
          await map.style.getSource(kGridCellSourceId) as mapbox.GeoJsonSource?;
      cellSrc?.updateGeoJSON(jsonEncode(cellJson));

      final labelSrc =
          await map.style.getSource(kGridLabelSourceId) as mapbox.GeoJsonSource?;
      labelSrc?.updateGeoJSON(jsonEncode(labelJson));
    } catch (_) {
      // Ignore errors during style transitions
    }
  }
}
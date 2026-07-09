import 'dart:convert';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../model/map_zone_model.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';
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

  // Viewport grid caching to avoid unnecessary GeoJSON updates
  List<String> _lastRenderedZoneIds = [];
  String _lastActiveStateSignature = '';

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
    // Instantly draw/update the local grid boundaries for the viewport
    await drawLocalGridInBounds(map, sw, ne);

    if (isInitialFetch) {
      isInitialFetch = false;
      await fetchZones(
        south: sw.latitude,
        north: ne.latitude,
        west: sw.longitude,
        east: ne.longitude,
        map: map,
      );
    } else {
      // API call debounce
      _cameraBounds.value = {
        'south': sw.latitude,
        'north': ne.latitude,
        'west': sw.longitude,
        'east': ne.longitude,
        'map': map,
      };
    }
  }

  /// Instantly draws grid boundaries in the viewport.
  Future<void> drawLocalGridInBounds(
    mapbox.MapboxMap map,
    LatLng sw,
    LatLng ne,
  ) async {
    try {
      final localZones = ZoneCalculator.zonesInBounds(
        south: sw.latitude,
        north: ne.latitude,
        west: sw.longitude,
        east: ne.longitude,
      );

      final zoneIds = localZones.map((z) => z.zoneId).toList();
      final activeMap = {for (var z in activeZones) z.id: z};
      
      // Calculate a signature representing active state within visible cells
      final activeStateSignature = localZones.map((z) {
        final az = activeMap[z.zoneId];
        return '${z.zoneId}_${az?.level.name ?? 'empty'}_${az?.count ?? 0}';
      }).join('|');

      bool isIdentical = zoneIds.length == _lastRenderedZoneIds.length;
      if (isIdentical) {
        for (int i = 0; i < zoneIds.length; i++) {
          if (zoneIds[i] != _lastRenderedZoneIds[i]) {
            isIdentical = false;
            break;
          }
        }
      }

      // Viewport grid lines and active colors match cache; skip Mapbox refresh
      if (isIdentical && _lastActiveStateSignature == activeStateSignature) {
        return;
      }

      _lastRenderedZoneIds = zoneIds;
      _lastActiveStateSignature = activeStateSignature;

      final features = localZones.map((zone) {
        final activeZone = activeMap[zone.zoneId];
        final level = activeZone?.level.name ?? 'empty';
        final count = activeZone?.count ?? 0;

        return {
          'type': 'Feature',
          'id': zone.zoneId,
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              [
                [zone.boundWest, zone.boundSouth],
                [zone.boundEast, zone.boundSouth],
                [zone.boundEast, zone.boundNorth],
                [zone.boundWest, zone.boundNorth],
                [zone.boundWest, zone.boundSouth],
              ]
            ],
          },
          'properties': {
            'id': zone.zoneId,
            'activityLevel': level,
            'reportCount': count,
            'label': count > 0 ? count.toString() : '',
          },
        };
      }).toList();

      final cellJson = {
        'type': 'FeatureCollection',
        'features': features,
      };

      final labelFeatures = <Map<String, dynamic>>[];
      for (final zone in localZones) {
        final activeZone = activeMap[zone.zoneId];
        final count = activeZone?.count ?? 0;
        if (count == 0) continue;
        labelFeatures.add({
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [zone.centerLng, zone.centerLat],
          },
          'properties': {
            'label': count.toString(),
            'activityLevel': activeZone?.level.name ?? 'empty',
          },
        });
      }

      final labelJson = {
        'type': 'FeatureCollection',
        'features': labelFeatures,
      };

      final cellSrc =
          await map.style.getSource(kGridCellSourceId) as mapbox.GeoJsonSource?;
      cellSrc?.updateGeoJSON(jsonEncode(cellJson));

      final labelSrc =
          await map.style.getSource(kGridLabelSourceId) as mapbox.GeoJsonSource?;
      labelSrc?.updateGeoJSON(jsonEncode(labelJson));
    } catch (_) {
      // Ignore style transition errors
    }
  }

  /// Refreshes the grid overlay on the map by retrieving latest coordinates.
  Future<void> refreshGridOnMap(mapbox.MapboxMap map) async {
    try {
      final cam = await map.getCameraState();
      final bounds = await map.coordinateBoundsForCamera(
        mapbox.CameraOptions(
          center: cam.center,
          zoom: cam.zoom,
          bearing: cam.bearing,
          pitch: cam.pitch,
          padding: mapbox.MbxEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        ),
      );

      final sw = LatLng(
        bounds.southwest.coordinates.lat.toDouble(),
        bounds.southwest.coordinates.lng.toDouble(),
      );
      final ne = LatLng(
        bounds.northeast.coordinates.lat.toDouble(),
        bounds.northeast.coordinates.lng.toDouble(),
      );

      await drawLocalGridInBounds(map, sw, ne);
    } catch (_) {}
  }

  // ── Tap → zone lookup ─────────────────────────────────────────────────

  MapZoneModel? zoneForCoordinate(double lat, double lng) {
    final zoneInfo = ZoneCalculator.fromLatLng(lat, lng);
    if (zoneInfo == null) return null;

    selectedCellId.value = zoneInfo.zoneId;

    // Check if we have an entry in activeZones matching this zoneId
    MapZoneModel? matched;
    for (final z in activeZones) {
      if (z.id == zoneInfo.zoneId) {
        matched = z;
        break;
      }
    }

    if (matched != null) {
      return matched;
    }

    // Return a default MapZoneModel (0 reports) for this zone
    return MapZoneModel(
      id: zoneInfo.zoneId,
      name: zoneInfo.zoneId,
      location: LatLng(zoneInfo.centerLat, zoneInfo.centerLng),
      count: 0,
      level: ActivityLevel.low,
      reports: 0,
      lastUpdated: 'No reports yet',
      activityScore: 0.0,
      topSpecies: 'None',
      avgDepth: '—',
      trend: TrendDirection.stable,
      north: zoneInfo.boundNorth,
      south: zoneInfo.boundSouth,
      east: zoneInfo.boundEast,
      west: zoneInfo.boundWest,
    );
  }

  void selectZone(MapZoneModel zone) => selectedZone.value = zone;
  void deselectZone() => selectedZone.value = null;

  // ── Mock data ─────────────────────────────────────────────────────────

  void loadMockData() {
    final zone1 = ZoneCalculator.fromLatLng(28.55, -88.45);
    final zone2 = ZoneCalculator.fromLatLng(28.62, -88.60);
    final zone3 = ZoneCalculator.fromLatLng(28.48, -88.52);
    final zone4 = ZoneCalculator.fromLatLng(28.45, -88.42);
    final zone5 = ZoneCalculator.fromLatLng(28.50, -88.30);
    final zone6 = ZoneCalculator.fromLatLng(28.53, -88.22);

    activeZones.assignAll([
      if (zone1 != null)
        MapZoneModel(
          id: zone1.zoneId, name: zone1.zoneId,
          location: LatLng(zone1.centerLat, zone1.centerLng),
          count: 12, level: ActivityLevel.high,
          reports: 24, lastUpdated: '6 hours ago',
          activityScore: 0.92, topSpecies: 'Tuna', avgDepth: '120 ft',
          trend: TrendDirection.rising,
          north: zone1.boundNorth, south: zone1.boundSouth,
          east: zone1.boundEast, west: zone1.boundWest,
        ),
      if (zone2 != null)
        MapZoneModel(
          id: zone2.zoneId, name: zone2.zoneId,
          location: LatLng(zone2.centerLat, zone2.centerLng),
          count: 8, level: ActivityLevel.high,
          reports: 17, lastUpdated: '2 hours ago',
          activityScore: 0.78, topSpecies: 'Marlin', avgDepth: '95 ft',
          trend: TrendDirection.stable,
          north: zone2.boundNorth, south: zone2.boundSouth,
          east: zone2.boundEast, west: zone2.boundWest,
        ),
      if (zone3 != null)
        MapZoneModel(
          id: zone3.zoneId, name: zone3.zoneId,
          location: LatLng(zone3.centerLat, zone3.centerLng),
          count: 3, level: ActivityLevel.medium,
          reports: 6, lastUpdated: '1 day ago',
          activityScore: 0.35, topSpecies: 'Snapper', avgDepth: '60 ft',
          trend: TrendDirection.falling,
          north: zone3.boundNorth, south: zone3.boundSouth,
          east: zone3.boundEast, west: zone3.boundWest,
        ),
      if (zone4 != null)
        MapZoneModel(
          id: zone4.zoneId, name: zone4.zoneId,
          location: LatLng(zone4.centerLat, zone4.centerLng),
          count: 1, level: ActivityLevel.low,
          reports: 3, lastUpdated: '5 hours ago',
          activityScore: 0.15, topSpecies: 'Wahoo', avgDepth: '140 ft',
          trend: TrendDirection.stable,
          north: zone4.boundNorth, south: zone4.boundSouth,
          east: zone4.boundEast, west: zone4.boundWest,
        ),
      if (zone5 != null)
        MapZoneModel(
          id: zone5.zoneId, name: zone5.zoneId,
          location: LatLng(zone5.centerLat, zone5.centerLng),
          count: 7, level: ActivityLevel.medium,
          reports: 14, lastUpdated: '30 min ago',
          activityScore: 0.68, topSpecies: 'Mahi', avgDepth: '110 ft',
          trend: TrendDirection.rising,
          north: zone5.boundNorth, south: zone5.boundSouth,
          east: zone5.boundEast, west: zone5.boundWest,
        ),
      if (zone6 != null)
        MapZoneModel(
          id: zone6.zoneId, name: zone6.zoneId,
          location: LatLng(zone6.centerLat, zone6.centerLng),
          count: 4, level: ActivityLevel.medium,
          reports: 9, lastUpdated: '4 hours ago',
          activityScore: 0.44, topSpecies: 'Sailfish', avgDepth: '200 ft',
          trend: TrendDirection.falling,
          north: zone6.boundNorth, south: zone6.boundSouth,
          east: zone6.boundEast, west: zone6.boundWest,
        ),
    ]);

    // Build activity map keyed by cell id
    activityMap.clear();
    for (final z in activeZones) {
      activityMap[z.id] = {'level': z.level.name, 'count': z.count};
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

          // If map is provided, update the grid layers immediately using local calculator
          if (map != null) {
            await refreshGridOnMap(map);
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
}
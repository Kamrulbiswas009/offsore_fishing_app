import 'dart:convert';

import 'package:flutter/material.dart';
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

  @override
  void onInit() {
    super.onInit();
    gridHelper = const ZoneGridHelper(
      origin: gridOrigin,
      cellMiles: 8.0,
    );
    loadMockData();
    fetchReportsAndPopulateMap();
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
  }

  // ── Dynamic grid refresh (called on every camera change) ──────────────

  /// Rebuilds GeoJSON sources to cover the current [sw]→[ne] viewport.
  Future<void> updateGridForBounds(
    mapbox.MapboxMap map,
    LatLng sw,
    LatLng ne,
  ) async {
    try {
      final cells = gridHelper.cellsForBounds(sw, ne, buffer: 2);

      final cellJson  = gridHelper.buildCellGeoJson(cells, activityMap);
      final labelJson = gridHelper.buildLabelGeoJson(cells, activityMap);

      final cellSrc =
          await map.style.getSource(kGridCellSourceId) as mapbox.GeoJsonSource?;
      cellSrc?.updateGeoJSON(jsonEncode(cellJson));

      final labelSrc =
          await map.style.getSource(kGridLabelSourceId) as mapbox.GeoJsonSource?;
      labelSrc?.updateGeoJSON(jsonEncode(labelJson));
    } catch (_) {
      // Ignore errors during rapid camera transitions
    }
  }

  // ── Tap → zone lookup ─────────────────────────────────────────────────

  MapZoneModel? zoneForCoordinate(double lat, double lng) {
    final cell = gridHelper.cellForCoordinate(LatLng(lat, lng));
    if (cell == null) return null;
    selectedCellId.value = cell.id;

    for (final z in activeZones) {
      final zCell = gridHelper.cellForCoordinate(z.location);
      if (zCell?.id == cell.id) return z;
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

  Future<void> fetchReportsAndPopulateMap() async {
    isLoading.value = true;
    try {
      final network = NetworkCaller();
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await network.getRequest(
        ApiConstants.getRegionReportsApi,
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          "Successfully fetched map reports. API: ${ApiConstants.getRegionReportsApi}, Response: ${response.responseData}",
        );
        final data = response.responseData['data'] as List?;
        if (data != null && data.isNotEmpty) {
          // Group reports by zoneId
          final Map<String, List<Map<String, dynamic>>> zoneReportsMap = {};
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final zoneId = item['zoneId'] ?? item['zone']?['zoneId'];
              if (zoneId != null) {
                zoneReportsMap.putIfAbsent(zoneId, () => []).add(item);
              }
            }
          }

          final List<MapZoneModel> dynamicZones = [];
          int zoneIndex = 1;

          zoneReportsMap.forEach((zoneId, reportsList) {
            // Calculate center coordinate
            double sumLat = 0;
            double sumLng = 0;
            int coordCount = 0;

            final Map<String, int> speciesCounts = {};
            int totalDepth = 0;
            int depthCount = 0;

            for (var report in reportsList) {
              final reportLat = report['reportLat'] ?? report['zone']?['centerLat'];
              final reportLng = report['reportLng'] ?? report['zone']?['centerLng'];
              if (reportLat != null && reportLng != null) {
                sumLat += (reportLat as num).toDouble();
                sumLng += (reportLng as num).toDouble();
                coordCount++;
              }

              final speciesList = report['species'] as List?;
              if (speciesList != null) {
                for (var s in speciesList) {
                  final name = s['speciesName'] ?? 'Unknown';
                  final qty = s['quantity'] ?? 1;
                  speciesCounts[name] = (speciesCounts[name] ?? 0) + (qty as int);
                }
              }

              final depth = report['waterDepthFt'];
              if (depth != null) {
                totalDepth += (depth as num).toInt();
                depthCount++;
              }
            }

            final lat = coordCount > 0 ? sumLat / coordCount : 28.5;
            final lng = coordCount > 0 ? sumLng / coordCount : -88.5;

            String topSpecies = 'None';
            int maxSpeciesCount = 0;
            speciesCounts.forEach((speciesName, count) {
              if (count > maxSpeciesCount) {
                maxSpeciesCount = count;
                topSpecies = speciesName;
              }
            });

            final avgDepthVal = depthCount > 0 ? totalDepth ~/ depthCount : 120;
            final count = reportsList.length;

            ActivityLevel level = ActivityLevel.low;
            if (count >= 5) {
              level = ActivityLevel.high;
            } else if (count >= 2) {
              level = ActivityLevel.medium;
            }

            dynamicZones.add(MapZoneModel(
              id: zoneIndex.toString(),
              name: zoneId,
              location: LatLng(lat, lng),
              count: count,
              level: level,
              reports: count,
              topSpecies: topSpecies,
              avgDepth: "${avgDepthVal} ft",
              activityScore: count / 10.0 > 1.0 ? 1.0 : count / 10.0,
              trend: TrendDirection.stable,
            ));
            zoneIndex++;
          });

          activeZones.assignAll(dynamicZones);

          activityMap.clear();
          for (final z in activeZones) {
            final cell = gridHelper.cellForCoordinate(z.location);
            if (cell == null) continue;
            activityMap[cell.id] = {'level': z.level.name, 'count': z.count};
          }
        }
      } else {
        AppLoggerHelper.error(
          "Failed to fetch map reports. StatusCode: ${response.statusCode}, Error: ${response.errorMessage}",
        );
      }
    } catch (e, stack) {
      AppLoggerHelper.error("Exception fetching map reports: $e", stack);
    } finally {
      isLoading.value = false;
    }
  }
}

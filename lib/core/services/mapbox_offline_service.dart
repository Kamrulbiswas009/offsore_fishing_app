import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

class MapboxOfflineService extends GetxService {
  static MapboxOfflineService get to => Get.find<MapboxOfflineService>();

  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isDownloading = false.obs;
  final RxString statusMessage = "Idle".obs;
  final RxInt storageUsedInMb = 0.obs;

  mapbox.OfflineManager? _offlineManager;
  mapbox.TileStore? _tileStore;

  // Predefined Gulf of Mexico boundary coordinates
  // SW: 24.0, -98.0 / NE: 31.0, -81.0
  final Map<String, dynamic> gulfOfMexicoGeometryMap = {
    "type": "Polygon",
    "coordinates": [
      [
        [-98.0, 24.0],
        [-81.0, 24.0],
        [-81.0, 31.0],
        [-98.0, 31.0],
        [-98.0, 24.0]
      ]
    ]
  };

  @override
  void onInit() {
    super.onInit();
    _initManagers();
  }

  Future<void> _initManagers() async {
    try {
      _offlineManager = await mapbox.OfflineManager.create();
      _tileStore = await mapbox.TileStore.createDefault();
      debugPrint('[MapboxOfflineService] Managers initialised successfully.');
    } catch (e) {
      debugPrint('[MapboxOfflineService] Failed to init Mapbox Managers: $e');
    }
  }

  Future<void> startOfflineDownload() async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadProgress.value = 0.0;
    statusMessage.value = "Starting download...";

    try {
      if (_offlineManager == null || _tileStore == null) {
        await _initManagers();
      }

      final offlineManager = _offlineManager;
      final tileStore = _tileStore;

      if (offlineManager == null || tileStore == null) {
        throw Exception("Mapbox Offline Managers are not available.");
      }

      // 1. Download Style Pack
      statusMessage.value = "Downloading style resources...";
      
      final stylePackOptions = mapbox.StylePackLoadOptions(
        glyphsRasterizationMode: mapbox.GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
        metadata: {'tag': 'satellite_streets_style'},
        acceptExpired: true,
      );

      final styleUri = mapbox.MapboxStyles.SATELLITE_STREETS;

      await offlineManager.loadStylePack(
        styleUri,
        stylePackOptions,
        (progress) {
          final percentage = (progress.completedResourceCount / progress.requiredResourceCount.clamp(1, double.infinity)) * 50.0;
          downloadProgress.value = percentage;
          statusMessage.value = "Downloading style resources: ${percentage.toStringAsFixed(0)}%";
        },
      );

      // 2. Download Tile Region
      statusMessage.value = "Downloading map tiles...";

      // Define tileset descriptors
      final tilesetDescriptor = mapbox.TilesetDescriptorOptions(
        styleURI: styleUri,
        minZoom: 0,
        maxZoom: 11,
      );

      final tileRegionOptions = mapbox.TileRegionLoadOptions(
        geometry: gulfOfMexicoGeometryMap,
        descriptorsOptions: [tilesetDescriptor],
        metadata: {'tag': 'gulf_of_mexico_region'},
        acceptExpired: true,
        networkRestriction: mapbox.NetworkRestriction.NONE,
      );

      await tileStore.loadTileRegion(
        'gulf_of_mexico_id',
        tileRegionOptions,
        (progress) {
          final tilePercent = (progress.completedResourceCount / progress.requiredResourceCount.clamp(1, double.infinity)) * 50.0;
          downloadProgress.value = 50.0 + tilePercent;
          statusMessage.value = "Downloading map tiles: ${(50.0 + tilePercent).toStringAsFixed(0)}%";
        },
      );

      downloadProgress.value = 100.0;
      isDownloading.value = false;
      statusMessage.value = "Download Complete!";
      storageUsedInMb.value = 85; // Mock storage used
      debugPrint('[MapboxOfflineService] Gulf of Mexico download complete.');
    } catch (e, stack) {
      isDownloading.value = false;
      statusMessage.value = "Download Failed";
      debugPrint('[MapboxOfflineService] Error downloading map: $e\n$stack');
    }
  }

  Future<void> clearOfflineMap() async {
    try {
      if (_tileStore != null) {
        await _tileStore!.removeRegion('gulf_of_mexico_id');
      }
      downloadProgress.value = 0.0;
      storageUsedInMb.value = 0;
      statusMessage.value = "Offline data cleared.";
      debugPrint('[MapboxOfflineService] Offline map cleared.');
    } catch (e) {
      debugPrint('[MapboxOfflineService] Error clearing map: $e');
    }
  }
}

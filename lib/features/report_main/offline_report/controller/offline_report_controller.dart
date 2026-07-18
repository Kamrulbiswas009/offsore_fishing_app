import 'dart:convert';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import '../model/offline_report_model.dart';
import 'package:paytonpieper/core/services/offline_cache_service.dart';

class OfflineReportsTabController extends GetxController {
  final SyncService _syncService = Get.find<SyncService>();

  var selectedTab = "Reports".obs;
  
  // Bind properties to SyncService reactively
  RxBool get isSyncing => _syncService.isSyncing;
  RxInt get pendingSyncCount => _syncService.pendingCount;

  // Filter Observables
  var speciesFilter = speciesHierarchy.expand((node) => node.allSelectableLeafNames).first.obs;
  var depthFilter = "100-200 ft".obs;
  var techniqueFilter = "Trolling".obs;
  var timeFilter = "24h".obs;

  // Filter Options
  final List<String> speciesOptions = speciesHierarchy.expand((node) => node.allSelectableLeafNames).toList();
  final List<String> depthOptions = [
    "0-50 ft",
    "50-100 ft",
    "100-200 ft",
    "200-500 ft",
    "500+ ft",
  ];
  final List<String> techniqueOptions = [
    "Trolling",
    "Bottom Fishing",
    "Jigging",
    "Casting",
    "Fly Fishing",
  ];
  final List<String> timeOptions = [
    "1h",
    "6h",
    "12h",
    "24h",
    "48h",
    "All Time",
  ];

  // Mock Data
  var reports = <OfflineReportModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
    // Re-load list when pending sync count updates
    ever(_syncService.pendingCount, (_) => loadReports());
  }

  Future<void> loadReports() async {
    final pending = await _syncService.getPendingReports();
    final List<OfflineReportModel> localReports = [];

    for (final row in pending) {
      try {
        final payload = jsonDecode(row['payload']) as Map<String, dynamic>;
        final patterns = payload['fishingPatterns'] as List?;
        
        String primarySpecies = 'Unknown';
        String method = 'Unknown';
        String bait = 'Unknown';
        String depth = '0ft';

        if (patterns != null && patterns.isNotEmpty) {
          final firstPattern = patterns.first as Map;
          final patternSpecies = firstPattern['species'] as List?;
          if (patternSpecies != null && patternSpecies.isNotEmpty) {
            primarySpecies = patternSpecies[0]['speciesName'] ?? 'Unknown';
          }
          method = firstPattern['fishingMethod'] ?? 'Unknown';
          bait = firstPattern['baitLureType'] ?? 'Unknown';
          depth = "${firstPattern['waterDepthFt'] ?? 0}ft";
        } else {
          final speciesList = payload['species'] as List?;
          primarySpecies = (speciesList != null && speciesList.isNotEmpty)
              ? speciesList[0]['speciesName']
              : 'Unknown';
          method = payload['fishingMethod'] ?? 'Unknown';
          bait = payload['baitLureType'] ?? 'Unknown';
          depth = "${payload['waterDepthFt'] ?? 0}ft";
        }

        final zone = payload['zoneId'] ?? 'Unknown';
        final note = payload['notes'];

        localReports.add(OfflineReportModel(
          id: row['frontendReportId'] ?? row['id'].toString(),
          species: primarySpecies,
          timeAgo: "Pending Sync (Offline)",
          depth: depth,
          zone: zone,
          technique: method,
          bait: bait,
          note: note,
          confirms: 0,
          isVerified: false,
        ));
      } catch (e) {
        // Ignore parsing errors
      }
    }

    final List<OfflineReportModel> cachedReports = [];
    try {
      final cacheService = Get.find<OfflineCacheService>();
      final cachedData = await cacheService.getCache("region_reports");
      if (cachedData != null && cachedData is Map && cachedData['data'] is List) {
        final List dataList = cachedData['data'];
        for (var item in dataList) {
          if (item is Map) {
            final speciesList = (item['allSpecies'] ?? item['species']) as List?;
            final speciesName = (speciesList != null && speciesList.isNotEmpty)
                ? speciesList.map((s) => s['speciesName']).join(', ')
                : 'Unknown';

            final catchTimestamp = item['catchTimestamp'] as String?;
            final timeAgo = _formatTimeAgo(catchTimestamp);

            final patterns = item['fishingPatterns'] as List?;
            String depth = "${item['waterDepthFt'] ?? 0}ft";
            String technique = _mapBackendMethodToUser(item['fishingMethod']);
            String bait = _mapBackendBaitToUser(item['baitLureType']);

            if (patterns != null && patterns.isNotEmpty) {
              final firstPattern = patterns.first as Map;
              if (firstPattern['waterDepthFt'] != null) {
                depth = "${firstPattern['waterDepthFt']}ft";
              }
              if (firstPattern['fishingMethod'] != null) {
                technique = _mapBackendMethodToUser(firstPattern['fishingMethod']);
              }
              if (firstPattern['baitLureType'] != null) {
                bait = _mapBackendBaitToUser(firstPattern['baitLureType']);
              }
            }

            final zone = item['zoneId'] ?? item['zone']?['zoneId'] ?? 'Unknown';
            final note = item['notes'];
            final confirms = item['biteConfirmations']?['confirmed'] ?? 0;
            final author = item['user']?['name'];

            cachedReports.add(OfflineReportModel(
              id: item['id']?.toString() ?? item['reportId']?.toString() ?? item['_id']?.toString() ?? '',
              species: speciesName,
              timeAgo: timeAgo,
              depth: depth,
              zone: zone,
              technique: technique,
              bait: bait,
              note: note,
              confirms: confirms,
              author: author,
              isVerified: true,
            ));
          }
        }
      }
    } catch (e) {
      // Ignore cache load errors
    }

    // Fall back to original mock reports only if both local pending and cache are empty
    if (localReports.isEmpty && cachedReports.isEmpty) {
      reports.assignAll([
        OfflineReportModel(
          id: "1",
          species: "Tuna",
          subSpecies: "Blackfin",
          timeAgo: "about 3 hours ago",
          depth: "120ft",
          zone: "Z1",
          technique: "Trolling",
          bait: "Live Ballyhoo",
          note: "Strong bite around the weedline",
          confirms: 3,
        ),
        OfflineReportModel(
          id: "2",
          species: "Tuna",
          timeAgo: "about 19 hours ago",
          depth: "65ft",
          zone: "Z6",
          technique: "Bottom Fishing",
          bait: "Cut bait",
          confirms: 2,
        ),
        OfflineReportModel(
          id: "3",
          species: "Tuna",
          subSpecies: "Blackfin",
          author: "Offshore Dan",
          timeAgo: "about 9 hours ago",
          depth: "150ft",
          zone: "Z5",
          technique: "Trolling",
          bait: "Live Ballyhoo",
          confirms: 4,
        ),
      ]);
    } else {
      reports.assignAll([
        ...localReports,
        ...cachedReports,
      ]);
    }
  }

  String _formatTimeAgo(String? timestampStr) {
    if (timestampStr == null) return "Unknown time";
    try {
      final dateTime = DateTime.parse(timestampStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.isNegative || difference.inSeconds < 60) {
        return "just now";
      } else if (difference.inMinutes < 60) {
        return "about ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
      } else if (difference.inHours < 24) {
        return "about ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
      } else {
        return "about ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
      }
    } catch (e) {
      return "Unknown time";
    }
  }

  String _mapBackendMethodToUser(String? method) {
    if (method == null) return "Unknown";
    final clean = method.trim().toUpperCase();
    if (clean == "BOTTOM_FISHING") return "Bottom Fishing";
    if (clean == "ANCHOR_SPOT_FISHING") return "Anchor Spot Fishing";
    if (clean == "FLY_FISHING") return "Fly Fishing";
    if (clean == "JIGGING") return "Jigging";
    if (clean == "TROLLING") return "Trolling";
    if (clean == "DRIFTING") return "Drifting";
    return clean.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _mapBackendBaitToUser(String? bait) {
    if (bait == null) return "Unknown";
    final clean = bait.trim().toUpperCase();
    if (clean == "LIVE_BALLYHOO") return "Live Ballyhoo";
    if (clean == "CUT_BAIT") return "Cut Bait";
    if (clean == "VERTICAL_JIG") return "Vertical Jig";
    if (clean == "SKIRTED_LURE") return "Skirted Lure";
    return clean.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void onConfirmBite(String id) {
    Get.rawSnackbar(message: "Bite confirmed for report #$id");
  }
}

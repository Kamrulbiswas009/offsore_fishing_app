import 'dart:convert';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import '../model/offline_report_model.dart';

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
        final speciesList = payload['species'] as List?;
        final primarySpecies = (speciesList != null && speciesList.isNotEmpty)
            ? speciesList[0]['speciesName']
            : 'Unknown';

        final method = payload['fishingMethod'] ?? 'Unknown';
        final bait = payload['baitLureType'] ?? 'Unknown';
        final depth = "${payload['waterDepthFt'] ?? 0}ft";
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

    reports.assignAll([
      ...localReports,
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
  }

  void onConfirmBite(String id) {
    Get.rawSnackbar(message: "Bite confirmed for report #$id");
  }
}

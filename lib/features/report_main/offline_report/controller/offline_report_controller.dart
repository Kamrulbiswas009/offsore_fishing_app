import 'package:get/get.dart';
import '../model/offline_report_model.dart';

class OfflineReportsTabController extends GetxController {
  var selectedTab = "Reports".obs;
  var isSyncing = true.obs;
  var pendingSyncCount = 2.obs;

  // Filter Observables
  var speciesFilter = "Tuna".obs;
  var depthFilter = "100-200 ft".obs;
  var techniqueFilter = "Trolling".obs;
  var timeFilter = "24h".obs;

  // Filter Options
  final List<String> speciesOptions = [
    "Tuna",
    "Marlin",
    "Mahi Mahi",
    "Snapper",
    "Grouper",
    "Sailfish",
  ];
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
  }

  void loadReports() {
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
  }

  void onConfirmBite(String id) {
    Get.rawSnackbar(message: "Bite confirmed for report #$id");
  }
}

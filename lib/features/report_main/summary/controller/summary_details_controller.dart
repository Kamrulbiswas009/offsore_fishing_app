import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/features/report_main/report/model/report_model.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';


class SummaryController extends GetxController {
  var selectedTab = "Summary".obs;
  var selectedTimeRange = "Last 3 Days".obs;

  final List<String> timeRangeOptions = [
    "Last 24 Hours",
    "Last 3 Days",
    "Last 7 Days",
    "Last 30 Days",
    "This Month",
    "Custom Range",
  ];

  void changeTimeRange(String range) {
    selectedTimeRange.value = range;
  }

  var selectedZone = Rxn<MapZoneModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is MapZoneModel) {
      selectedZone.value = Get.arguments;
    }
    fetchReports();
  }

  List<BarChartGroupData> get activityData => [
    _makeGroupData(0, 3),
    _makeGroupData(1, 5),
    _makeGroupData(2, 8),
    _makeGroupData(3, 4),
    _makeGroupData(4, 7),
    _makeGroupData(5, 8),
    _makeGroupData(6, 6),
    _makeGroupData(7, 3),
    _makeGroupData(8, 2),
    _makeGroupData(9, 4),
    _makeGroupData(10, 8),
    _makeGroupData(11, 7),
  ];

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFFE25301),
          width: 6,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ],
    );
  }

  void onAddReport() => Get.to(ReportCatchStep1Screen());

  // Filter States
  var selectedSpecies = "".obs;
  var selectedDepth = "".obs;
  var selectedTechnique = "".obs;
  var selectedTime = "".obs;
  var selectedReportType = "".obs;

  void resetFilters() {
    selectedSpecies.value = "";
    selectedDepth.value = "";
    selectedTechnique.value = "";
    selectedTime.value = "";
    selectedReportType.value = "";
  }

  final List<String> speciesList = [
    "Tuna",
    "Marlin",
    "Mahi",
    "Snapper",
    "Grouper",
    "Wahoo",
  ];
  final List<String> depthList = [
    "0-50 ft",
    "50-100 ft",
    "100-200 ft",
    "200-500 ft",
    "500+ ft",
  ];
  final List<String> techniqueList = [
    "Trolling",
    "Bottom Fishing",
    "Jigging",
    "Fly Fishing",
    "Drifting",
  ];
  final List<String> timeList = ["6h", "12h", "24h", "48h", "Week"];
  final List<String> reportTypeList = ["Public", "Group", "My reports"];

  final RxList<FishingReport> reports = <FishingReport>[
    FishingReport(
      title: "Tuna (Blackfin)",
      timeAgo: "about 3 hours ago",
      depth: "120ft",
      zone: "Z1",
      technique: "Trolling",
      bait: "Live Ballyhoo",
      note: "Strong bite around the weedline",
      confirms: 3,
      type: "public",
    ),
    FishingReport(
      title: "Tuna",
      timeAgo: "about 19 hours ago",
      depth: "65ft",
      zone: "Z6",
      technique: "Bottom Fishing",
      bait: "Cut bait",
      confirms: 2,
      type: "Group",
    ),
    FishingReport(
      title: "Tuna (Blackfin)",
      timeAgo: "about 9 hours ago",
      author: "Offshore Dan",
      depth: "150ft",
      zone: "Z5",
      technique: "Trolling",
      bait: "Live Ballyhoo",
      confirms: 4,
      type: "My reports",
    ),
  ].obs;

  Future<void> fetchReports() async {
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
          "Successfully fetched region reports. API: ${ApiConstants.getRegionReportsApi}, Response: ${response.responseData}",
        );
        final data = response.responseData['data'] as List?;
        if (data != null) {
          final List<FishingReport> fetchedList = [];
          for (var item in data) {
            try {
              final speciesList = item['species'] as List?;
              final title = (speciesList != null && speciesList.isNotEmpty)
                  ? speciesList.map((s) => s['speciesName']).join(', ')
                  : 'Unknown';

              final catchTimestamp = item['catchTimestamp'] as String?;
              final timeAgo = _formatTimeAgo(catchTimestamp);

              final depth = "${item['waterDepthFt'] ?? 0}ft";
              final zone = item['zoneId'] ?? item['zone']?['zoneId'] ?? 'Unknown';
              final technique = _mapBackendMethodToUser(item['fishingMethod']);
              final bait = _mapBackendBaitToUser(item['baitLureType']);
              final note = item['notes'];
              final confirms = item['biteConfirmations']?['confirmed'] ?? 0;
              final author = item['user']?['name'];
              final type = item['visibility']?.toString().toLowerCase() ?? 'public';

              fetchedList.add(FishingReport(
                title: title,
                timeAgo: timeAgo,
                depth: depth,
                zone: zone,
                technique: technique,
                bait: bait,
                note: note,
                confirms: confirms,
                author: author,
                type: type,
              ));
            } catch (e) {
              debugPrint("Error parsing report item: $e");
            }
          }
          reports.assignAll(fetchedList);
        }
      } else {
        debugPrint("Failed to fetch reports: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Exception fetching reports: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _formatTimeAgo(String? timestampStr) {
    if (timestampStr == null) return "Unknown time";
    try {
      final dateTime = DateTime.parse(timestampStr);
      final difference = DateTime.now().difference(dateTime);

      if (difference.inSeconds < 60) {
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
    
    // Capitalize first letter of each word if not specifically mapped
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

  List<FishingReport> get filteredReports {
    if (selectedSpecies.isEmpty &&
        selectedDepth.isEmpty &&
        selectedTechnique.isEmpty &&
        selectedTime.isEmpty &&
        selectedReportType.isEmpty) {
      return reports;
    }

    return reports.where((report) {
      // 1. Species Filter
      if (selectedSpecies.isNotEmpty) {
        if (!report.title.toLowerCase().contains(
          selectedSpecies.value.toLowerCase(),
        )) {
          return false;
        }
      }

      // 2. Depth Filter
      if (selectedDepth.isNotEmpty) {
        final cleanReportDepth = int.tryParse(
          report.depth.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        if (cleanReportDepth != null) {
          final range = selectedDepth.value;
          if (range == "0-50 ft" &&
              (cleanReportDepth < 0 || cleanReportDepth > 50)) {
            return false;
          }
          if (range == "50-100 ft" &&
              (cleanReportDepth < 50 || cleanReportDepth > 100)) {
            return false;
          }
          if (range == "100-200 ft" &&
              (cleanReportDepth < 100 || cleanReportDepth > 200)) {
            return false;
          }
          if (range == "200-500 ft" &&
              (cleanReportDepth < 200 || cleanReportDepth > 500)) {
            return false;
          }
          if (range == "500+ ft" && cleanReportDepth < 500) return false;
        }
      }

      // 3. Technique Filter
      if (selectedTechnique.isNotEmpty) {
        if (report.technique.toLowerCase() !=
            selectedTechnique.value.toLowerCase()) {
          return false;
        }
      }

      // 4. Time Filter
      if (selectedTime.isNotEmpty) {
        final cleanReportHour = int.tryParse(
          report.timeAgo.replaceAll(RegExp(r'[^0-9]'), ''),
        );
        if (cleanReportHour != null) {
          final limit = selectedTime.value;
          if (limit == "6h" && cleanReportHour > 6) return false;
          if (limit == "12h" && cleanReportHour > 12) return false;
          if (limit == "24h" && cleanReportHour > 24) return false;
          if (limit == "48h" && cleanReportHour > 48) return false;
        }
      }

      // 5. Report Type Filter
      if (selectedReportType.isNotEmpty) {
        if (report.type.toLowerCase() !=
            selectedReportType.value.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void confirmBite(int index) {
    Get.snackbar(
      "Confirmed",
      "You confirmed this bite!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }
  // Main Tab (Summary, Reports, Weather)

  // Weather Sub-Tabs
  var selectedWeatherType = "Forecast".obs; // Now or Forecast
  var selectedDay = "Today".obs;
  var selectedTimePeriod = "Morning".obs; // Morning, Afternoon, Evening

  final List<String> days = ["Today", "Sat 19", "Sun 20", "Mon 21", "Tue 22"];
  final List<String> timePeriods = ["Morning", "Afternoon", "Evening"];
}

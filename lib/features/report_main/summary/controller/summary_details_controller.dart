import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/features/report_main/report/model/report_model.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/services/offline_cache_service.dart';
import 'package:paytonpieper/core/services/sync_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/core/models/species_node.dart';


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

  // Offline caching states
  var offlineZones = <String>[].obs;
  var isDownloadingZone = false.obs;
  var downloadingZoneName = "".obs;

  bool get isCurrentZoneOffline => selectedZone.value != null && offlineZones.contains(selectedZone.value!.name);

  // Summary Tab API States
  var isSummaryLoading = false.obs;
  var summaryReportsCount = 53.obs;
  var summaryHitRate = "78%".obs;
  var summaryNetworksCount = 3.obs;
  var summaryHotZonesCount = 2.obs;
  
  var summaryTopSpecies = <Map<String, dynamic>>[
    {"name": "Tuna", "count": 16},
    {"name": "Snapper", "count": 12},
    {"name": "Grouper", "count": 8},
    {"name": "Mahi", "count": 6},
    {"name": "Wahoo", "count": 5},
  ].obs;

  var patternSummaryText = "—".obs;
  var patternDepth = "120-180 ft".obs;
  var patternBait = "Blue/White Ilander".obs;
  var patternMethod = "Trolling".obs;
  var patternStrikeZone = "Mid Column / Thermocline".obs;

  var peakWindow = "6.00 AM - 10.00 AM".obs;
  var effectiveMethod = "Trolling".obs;
  
  var hourlyHistogram = <double>[
    0.0, 0.0, 3.0, 2.0, 1.0, 0.0, 1.0, 0.0, 0.0, 45.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
  ].obs;

  var speciesDistribution = <Map<String, dynamic>>[
    {"name": "Others", "percentage": 40.0},
    {"name": "Tuna", "percentage": 25.0},
    {"name": "Snapper", "percentage": 20.0},
    {"name": "Grouper", "percentage": 15.0},
  ].obs;

  var lastUpdatedTime = Rxn<DateTime>();

  String get lastUpdatedText {
    final time = lastUpdatedTime.value;
    if (time == null) return "Updated —";
    final difference = DateTime.now().difference(time);
    if (difference.inSeconds < 60) {
      return "Updated just now";
    } else if (difference.inMinutes < 60) {
      return "Updated ${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "Updated ${difference.inHours} hr ago";
    } else {
      return "Updated ${difference.inDays} day ago";
    }
  }

  @override
  void onInit() {
    super.onInit();
    offlineZones.assignAll(StorageService.getOfflineZones());
    if (Get.arguments is MapZoneModel) {
      selectedZone.value = Get.arguments;
    }
    fetchReports();
    fetchSummary();
    fetchWeather();

    // Automatically reload cached/live data when connectivity changes
    try {
      final syncService = Get.find<SyncService>();
      ever(syncService.isOnline, (bool online) {
        if (online) {
          fetchReports();
          fetchSummary();
          fetchWeather();
        }
      });
    } catch (_) {}
  }

  void setZoneAndFetch(dynamic argument) {
    if (argument is MapZoneModel) {
      if (selectedZone.value?.id != argument.id) {
        selectedZone.value = argument;
        fetchReports();
        fetchSummary();
        fetchWeather();
      }
    }
  }

  void clearZoneAndFetch() {
    if (selectedZone.value != null) {
      selectedZone.value = null;
      fetchReports();
      fetchSummary();
      fetchWeather();
    }
  }

  List<BarChartGroupData> get activityData {
    if (hourlyHistogram.isEmpty) {
      return List.generate(12, (index) => _makeGroupData(index, 0.0));
    }
    return List.generate(hourlyHistogram.length, (index) {
      return _makeGroupData(index, hourlyHistogram[index]);
    });
  }

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

  final List<String> speciesList = speciesHierarchy.expand((node) => node.allSelectableLeafNames).toList();
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

  Future<void> fetchReports({int? customTtl, bool forceRefresh = false}) async {
    isLoading.value = true;

    // Load from cache instantly if available
    try {
      final cacheService = Get.find<OfflineCacheService>();
      final cachedData = await cacheService.getCache("region_reports", ignoreExpiry: true);
      if (cachedData != null && cachedData is Map && cachedData['data'] is List) {
        _parseReportsList(cachedData['data'] as List);
      }
    } catch (e) {
      debugPrint("Instant local cache load error (reports): $e");
    }

    try {
      final network = NetworkCaller();
      var accessToken = StorageService.token;
      if (accessToken == null || accessToken.isEmpty) {
        accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMDYxM2ViMC0zY2E4LTQ1MjItOTA4MC1hODM1NzFkZDdkODAiLCJlbWFpbCI6InVzZXJAZ21haWwuY29tIiwiaWF0IjoxNzgzMzAyMzM0LCJleHAiOjE3ODM5MDcxMzR9.3d1C44JOmw7aIpq6gna6kIrzXNfwVlaWkFfZxuaHYFo";
      }
      final token = 'Bearer $accessToken';

      final ttl = customTtl ?? (isCurrentZoneOffline ? 52560000 : 1440);

      final response = await network.cachedGetRequest(
        ApiConstants.getRegionReportsApi,
        token: token,
        cacheKey: "region_reports",
        ttlMinutes: ttl,
        forceRefresh: forceRefresh,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          "Successfully fetched region reports. API: ${ApiConstants.getRegionReportsApi}, Response: ${response.responseData}",
        );
        final data = response.responseData['data'] as List?;
        if (data != null) {
          _parseReportsList(data);
        }
        final timestampStr = response.responseData['timestamp'] as String?;
        if (timestampStr != null) {
          lastUpdatedTime.value = DateTime.tryParse(timestampStr) ?? DateTime.now();
        } else {
          lastUpdatedTime.value = DateTime.now();
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

  void _parseReportsList(List data) {
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
        final id = item['id']?.toString() ?? item['reportId']?.toString() ?? item['_id']?.toString();

        fetchedList.add(FishingReport(
          id: id,
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

  int get reportsLast24h {
    final list = selectedZone.value != null
        ? reports.where((r) => r.zone.toLowerCase() == selectedZone.value!.name.toLowerCase())
        : reports;
    int count = 0;
    for (var r in list) {
      if (r.timeAgo.contains("hour") || r.timeAgo.contains("minute") || r.timeAgo.contains("now")) {
        count++;
      } else if (r.timeAgo.contains("1 day")) {
        count++;
      }
    }
    return count;
  }

  List<FishingReport> get filteredReports {
    final zoneFiltered = selectedZone.value != null
        ? reports.where((r) => r.zone.toLowerCase() == selectedZone.value!.name.toLowerCase()).toList()
        : reports;

    if (selectedSpecies.isEmpty &&
        selectedDepth.isEmpty &&
        selectedTechnique.isEmpty &&
        selectedTime.isEmpty &&
        selectedReportType.isEmpty) {
      return zoneFiltered;
    }

    return zoneFiltered.where((report) {
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
    if (index < 0 || index >= filteredReports.length) return;
    final report = filteredReports[index];
    final reportId = report.id;

    if (reportId == null || reportId.isEmpty) {
      EasyLoading.showError("This report does not have a valid ID.");
      return;
    }

    EasyLoading.show(status: 'Confirming bite...');
    _confirmBiteAsync(reportId);
  }

  Future<void> _confirmBiteAsync(String reportId) async {
    try {
      final network = NetworkCaller();
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await network.postRequest(
        ApiConstants.confirmReportApi(reportId),
        token: token,
      );

      EasyLoading.dismiss();

      if (response.isSuccess) {
        AppLoggerHelper.info("Bite confirmed successfully for report ID: $reportId");
        EasyLoading.showSuccess("Bite confirmed successfully!");
        fetchReports();
      } else {
        AppLoggerHelper.error(
          "Failed to confirm bite for report ID: $reportId. StatusCode: ${response.statusCode}, Error: ${response.errorMessage}",
        );
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : "Failed to confirm bite.",
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      AppLoggerHelper.error("Error confirming bite for report ID: $reportId", e);
      EasyLoading.showError("An unexpected error occurred.");
    }
  }

  void rejectBite(int index) {
    if (index < 0 || index >= filteredReports.length) return;
    final report = filteredReports[index];
    final reportId = report.id;

    if (reportId == null || reportId.isEmpty) {
      EasyLoading.showError("This report does not have a valid ID.");
      return;
    }

    EasyLoading.show(status: 'Rejecting bite...');
    _rejectBiteAsync(reportId);
  }

  Future<void> _rejectBiteAsync(String reportId) async {
    try {
      final network = NetworkCaller();
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await network.postRequest(
        ApiConstants.rejectReportApi(reportId),
        token: token,
      );

      EasyLoading.dismiss();

      if (response.isSuccess) {
        AppLoggerHelper.info("Bite rejected successfully for report ID: $reportId");
        EasyLoading.showSuccess("Bite rejected successfully!");
        fetchReports();
      } else {
        AppLoggerHelper.error(
          "Failed to reject bite for report ID: $reportId. StatusCode: ${response.statusCode}, Error: ${response.errorMessage}",
        );
        EasyLoading.showError(
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : "Failed to reject bite.",
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      AppLoggerHelper.error("Error rejecting bite for report ID: $reportId", e);
      EasyLoading.showError("An unexpected error occurred.");
    }
  }
  // Main Tab (Summary, Reports, Weather)

  // Weather Sub-Tabs
  var selectedWeatherType = "Forecast".obs; // Now or Forecast
  var selectedDay = "Today".obs;
  var selectedTimePeriod = "Morning".obs; // Morning, Afternoon, Evening

  var days = RxList<String>(_generateInitialDays());
  final List<String> timePeriods = ["Morning", "Afternoon", "Evening"];

  static List<String> _generateInitialDays() {
    final List<String> list = ["Today"];
    final List<String> weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    for (int i = 1; i <= 4; i++) {
      final futureDate = DateTime.now().add(Duration(days: i));
      final label = "${weekdays[futureDate.weekday % 7]} ${futureDate.day}";
      list.add(label);
    }
    return list;
  }

  // StormGlass Weather API States
  var isWeatherLoading = false.obs;
  var weatherData = Rxn<Map<String, dynamic>>();

  Future<void> fetchSummary({int? customTtl, bool forceRefresh = false}) async {
    isSummaryLoading.value = true;
    
    final cacheKey = selectedZone.value != null
        ? "zone_summary_${selectedZone.value!.name}"
        : "zone_summary_region";

    // Load from cache instantly if available
    try {
      final cacheService = Get.find<OfflineCacheService>();
      final cachedData = await cacheService.getCache(cacheKey, ignoreExpiry: true);
      if (cachedData != null && cachedData is Map && cachedData['data'] is Map<String, dynamic>) {
        parseSummaryData(cachedData['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Instant local cache load error (summary): $e");
    }

    try {
      final network = NetworkCaller();
      var accessToken = StorageService.token;
      if (accessToken == null || accessToken.isEmpty) {
        accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMDYxM2ViMC0zY2E4LTQ1MjItOTA4MC1hODM1NzFkZDdkODAiLCJlbWFpbCI6InVzZXJAZ21haWwuY29tIiwiaWF0IjoxNzgzMzAyMzM0LCJleHAiOjE3ODM5MDcxMzR9.3d1C44JOmw7aIpq6gna6kIrzXNfwVlaWkFfZxuaHYFo";
      }
      final token = 'Bearer $accessToken';

      final String url;
      if (selectedZone.value != null) {
        url = "${ApiConstants.getZoneSummaryApi}?zoneId=${selectedZone.value!.name}&page=1&limit=20";
      } else {
        url = "${ApiConstants.getZoneSummaryApi}?regionCode=GOM&page=1&limit=20";
      }

      final ttl = customTtl ?? (isCurrentZoneOffline ? 52560000 : 1440);

      final response = await network.cachedGetRequest(
        url,
        token: token,
        cacheKey: cacheKey,
        ttlMinutes: ttl,
        forceRefresh: forceRefresh,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          "Successfully fetched zone summary. URL: $url, Response: ${response.responseData}",
        );
        final data = response.responseData['data'];
        if (data != null && data is Map<String, dynamic>) {
          parseSummaryData(data);
        }
        final timestampStr = response.responseData['timestamp'] as String?;
        if (timestampStr != null) {
          lastUpdatedTime.value = DateTime.tryParse(timestampStr) ?? DateTime.now();
        } else {
          lastUpdatedTime.value = DateTime.now();
        }
      } else {
        debugPrint("Failed to fetch zone summary: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Exception fetching zone summary: $e");
    } finally {
      isSummaryLoading.value = false;
    }
  }

  void parseSummaryData(Map<String, dynamic>? data) {
    if (data == null) return;
    // 1. Activity Overview
    final overview = data['activityOverview'];
    if (overview != null && overview is Map<String, dynamic>) {
      summaryReportsCount.value = overview['reportsCount'] ?? 0;
      summaryHitRate.value = "${overview['hitRate'] ?? 0}%";
      summaryNetworksCount.value = overview['networks'] ?? 0;
      summaryHotZonesCount.value = overview['hotZonesCount'] ?? 0;
    }

    // Update selectedZone dynamically with backend details if available
    final singleZone = data['singleZoneDetails'];
    if (singleZone != null && singleZone is Map<String, dynamic> && selectedZone.value != null) {
      final current = selectedZone.value!;
      double scoreVal = (singleZone['activityScore'] as num?)?.toDouble() ?? (current.activityScore * 100);
      if (scoreVal > 1.0) {
        scoreVal = scoreVal / 100.0;
      }
      final trendStr = singleZone['trendDirection'] as String?;
      TrendDirection trendDir = TrendDirection.stable;
      if (trendStr != null) {
        if (trendStr.toUpperCase() == "RISING" || trendStr.toUpperCase() == "UP") {
          trendDir = TrendDirection.rising;
        } else if (trendStr.toUpperCase() == "FALLING" || trendStr.toUpperCase() == "DOWN") {
          trendDir = TrendDirection.falling;
        }
      }

      final reportsCount = overview?['reportsCount'] as int? ?? current.reports;

      selectedZone.value = MapZoneModel(
        id: current.id,
        name: current.name,
        location: current.location,
        count: current.count,
        level: scoreVal >= 0.7 ? ActivityLevel.high : (scoreVal >= 0.4 ? ActivityLevel.medium : ActivityLevel.low),
        reports: reportsCount,
        lastUpdated: current.lastUpdated,
        activityScore: scoreVal,
        topSpecies: current.topSpecies,
        avgDepth: current.avgDepth,
        trend: trendDir,
        north: current.north,
        south: current.south,
        east: current.east,
        west: current.west,
      );
    }

    // 2. Top Species
    final topSp = data['topSpecies'] as List?;
    if (topSp != null) {
      summaryTopSpecies.assignAll(topSp.map((item) {
        return {
          "name": item['name'] ?? 'Unknown',
          "count": item['count'] ?? 0,
        };
      }).toList());
    }

    // 3. Pattern Intelligence
    final pattern = data['patternIntelligence'];
    if (pattern != null && pattern is Map<String, dynamic>) {
      patternSummaryText.value = pattern['summaryText'] ?? "—";
      final minD = pattern['commonDepthMinFt'];
      final maxD = pattern['commonDepthMaxFt'];
      if (minD != null && maxD != null) {
        patternDepth.value = minD == maxD ? "${minD} ft" : "${minD}-${maxD} ft";
      } else {
        patternDepth.value = "—";
      }

      patternBait.value = _mapBackendBaitToUser(pattern['topBaitLure']);
      patternMethod.value = _mapBackendMethodToUser(pattern['dominantMethod']);
      patternStrikeZone.value = _mapBackendColumnToUser(pattern['topWaterColumn']);
    }

    // 4. Activity Timing
    final timing = data['activityTiming'];
    if (timing != null && timing is Map<String, dynamic>) {
      peakWindow.value = timing['peakWindow'] ?? "—";
      effectiveMethod.value = _mapBackendMethodToUser(timing['mostEffectiveMethod']);

      final histogram = timing['hourlyHistogram'] as List?;
      if (histogram != null) {
        hourlyHistogram.assignAll(histogram.map((item) => (item as num).toDouble()).toList());
      }
    }

    // 5. Species Distribution
    final dist = data['speciesDistribution'] as List?;
    if (dist != null) {
      speciesDistribution.assignAll(dist.map((item) {
        return {
          "name": item['name'] ?? 'Others',
          "percentage": (item['percentage'] as num).toDouble(),
        };
      }).toList());
    }
  }

  String _mapBackendColumnToUser(String? column) {
    if (column == null) return "Unknown";
    final clean = column.trim().toUpperCase();
    if (clean == "MID_COLUMN") return "Mid Column";
    if (clean == "TOP_COLUMN" || clean == "SURFACE") return "Top Column";
    if (clean == "BOTTOM" || clean == "BOTTOM_COLUMN") return "Bottom";
    
    return clean.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0] + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Computes the geographic centre of the zone boundary.
  /// Uses (north+south)/2 and (east+west)/2 when all bounds are present.
  /// Falls back to the stored [MapZoneModel.location] centroid, then to a
  /// Gulf-of-Mexico default if no zone is selected.
  (double lat, double lng) get _weatherLatLng {
    final zone = selectedZone.value;
    if (zone != null) {
      final n = zone.north;
      final s = zone.south;
      final e = zone.east;
      final w = zone.west;
      if (n != null && s != null && e != null && w != null) {
        // Bounds-derived centre — most accurate
        return ((n + s) / 2.0, (e + w) / 2.0);
      }
      // Fall back to stored centroid
      return (zone.location.latitude, zone.location.longitude);
    }
    // No zone selected — use Gulf of Mexico region centre
    return (28.375, -89.125);
  }

  Future<void> fetchWeather({int? customTtl, bool forceRefresh = false}) async {
    isWeatherLoading.value = true;
    final (lat, lng) = _weatherLatLng;
    final cacheKey = "weather_${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}";

    // Load from cache instantly if available
    try {
      final cacheService = Get.find<OfflineCacheService>();
      final cachedData = await cacheService.getCache(cacheKey, ignoreExpiry: true);
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        weatherData.value = cachedData;
        final hours = cachedData['hours'] as List?;
        if (hours != null) {
          _populateDaysList(hours);
        }
      }
    } catch (e) {
      debugPrint("Instant local cache load error (weather): $e");
    }

    try {
      final network = NetworkCaller();
      final url = "https://api.stormglass.io/v2/weather/point?lat=$lat&lng=$lng&params=windSpeed,windDirection,waveHeight,waterTemperature,airTemperature,cloudCover,swellDirection,swellPeriod";

      final ttl = customTtl ?? (isCurrentZoneOffline ? 52560000 : 1440);

      final response = await network.cachedGetRequest(
        url,
        token: ApiConstants.stormGlassApiKey,
        cacheKey: cacheKey,
        ttlMinutes: ttl,
        forceRefresh: forceRefresh,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          "Successfully fetched StormGlass weather. Response: ${response.responseData}",
        );
        final data = response.responseData;
        if (data is Map<String, dynamic>) {
          weatherData.value = data;
          final hours = data['hours'] as List?;
          if (hours != null) {
            _populateDaysList(hours);
          }
        }
      } else {
        debugPrint("Failed to fetch weather from StormGlass: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Exception fetching weather: $e");
    } finally {
      isWeatherLoading.value = false;
    }
  }

  void _populateDaysList(List hours) {
    final List<String> computed = ["Today"];
    final Set<String> uniqueDates = {};
    final nowStr = DateTime.now().toIso8601String().substring(0, 10);
    final List<String> weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    for (var item in hours) {
      final timeStr = item['time'] as String?;
      if (timeStr == null) continue;
      try {
        final dt = DateTime.parse(timeStr).toLocal();
        final dateStr = dt.toIso8601String().substring(0, 10);
        if (dateStr == nowStr) continue;
        if (uniqueDates.contains(dateStr)) continue;

        uniqueDates.add(dateStr);
        final label = "${weekdays[dt.weekday % 7]} ${dt.day}";
        computed.add(label);
      } catch (_) {}
    }

    days.assignAll(computed.take(5).toList());
    if (!days.contains(selectedDay.value)) {
      selectedDay.value = "Today";
    }
  }

  Map<String, dynamic>? getSelectedDayNowEntry(String dayLabel) {
    final hours = weatherData.value?['hours'] as List?;
    if (hours == null || hours.isEmpty) return null;

    DateTime targetDate = DateTime.now();
    if (dayLabel != "Today") {
      final List<String> weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      for (var item in hours) {
        final timeStr = item['time'] as String?;
        if (timeStr == null) continue;
        try {
          final dt = DateTime.parse(timeStr).toLocal();
          final label = "${weekdays[dt.weekday % 7]} ${dt.day}";
          if (label == dayLabel) {
            targetDate = dt;
            break;
          }
        } catch (_) {}
      }
    }

    final targetHour = DateTime.now().hour;
    Map<String, dynamic>? bestMatch;
    double minDiff = double.infinity;

    for (var item in hours) {
      final timeStr = item['time'] as String?;
      if (timeStr == null) continue;
      try {
        final dt = DateTime.parse(timeStr).toLocal();
        final diff = DateTime(dt.year, dt.month, dt.day, dt.hour)
            .difference(DateTime(targetDate.year, targetDate.month, targetDate.day, targetHour))
            .inHours
            .abs();
        if (diff < minDiff) {
          minDiff = diff.toDouble();
          bestMatch = item as Map<String, dynamic>?;
        }
      } catch (_) {}
    }

    return bestMatch;
  }

  Map<String, dynamic>? get selectedDayNowEntry {
    return getSelectedDayNowEntry(selectedDay.value);
  }

  String get currentWindSpeed {
    final data = selectedDayNowEntry;
    if (data == null) return "12 mph";
    final val = extractSgValue(data['windSpeed']);
    if (val == null) return "12 mph";
    final mph = val * 2.237;
    return "${mph.toStringAsFixed(1)} mph";
  }

  String get currentWindDirection {
    final data = selectedDayNowEntry;
    if (data == null) return "NE";
    final val = extractSgValue(data['windDirection']);
    if (val == null) return "NE";
    return degreesToCardinal(val);
  }

  String degreesToCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) % 360 / 45).floor();
    return directions[index % 8];
  }

  String get currentWaveHeight {
    final data = selectedDayNowEntry;
    if (data == null) return "2.5 ft";
    final val = extractSgValue(data['waveHeight']);
    if (val == null) return "2.5 ft";
    final feet = val * 3.281;
    return "${feet.toStringAsFixed(1)} ft";
  }

  String get currentWaterTemp {
    final data = selectedDayNowEntry;
    if (data == null) return "78°F";
    final val = extractSgValue(data['waterTemperature']);
    if (val == null) return "78°F";
    final f = (val * 9 / 5) + 32;
    return "${f.toStringAsFixed(1)}°F";
  }

  String get currentAirTemp {
    final data = selectedDayNowEntry;
    if (data == null) return "82°F";
    final val = extractSgValue(data['airTemperature']);
    if (val == null) return "82°F";
    final f = (val * 9 / 5) + 32;
    return "${f.toStringAsFixed(1)}°F";
  }

  String get currentCloudCover {
    final data = selectedDayNowEntry;
    if (data == null) return "25%";
    final val = extractSgValue(data['cloudCover']);
    if (val == null) return "25%";
    return "${val.toInt()}%";
  }

  String get marineWindSpeed {
    final data = selectedDayNowEntry;
    if (data == null) return "12";
    final val = extractSgValue(data['windSpeed']);
    if (val == null) return "12";
    final mph = val * 2.237;
    return mph.toStringAsFixed(0);
  }

  String get marineWindDirection => currentWindDirection;

  String get marineWaveHeight {
    final data = selectedDayNowEntry;
    if (data == null) return "2.5";
    final val = extractSgValue(data['waveHeight']);
    if (val == null) return "2.5";
    final feet = val * 3.281;
    return feet.toStringAsFixed(1);
  }

  String get marineWaterTemp {
    final data = selectedDayNowEntry;
    if (data == null) return "78°";
    final val = extractSgValue(data['waterTemperature']);
    if (val == null) return "78°";
    final f = (val * 9 / 5) + 32;
    return "${f.toStringAsFixed(0)}°";
  }

  String get currentSwellDirection {
    final data = selectedDayNowEntry;
    if (data == null) return "SE";
    final val = extractSgValue(data['swellDirection']);
    if (val == null) return "SE";
    return degreesToCardinal(val);
  }

  String get currentSwellPeriod {
    final data = selectedDayNowEntry;
    if (data == null) return "9–12s";
    final val = extractSgValue(data['swellPeriod']);
    if (val == null) return "9–12s";
    return "${val.toStringAsFixed(0)}s";
  }

  String get currentSwellPeriodSeconds {
    final data = selectedDayNowEntry;
    if (data == null) return "8 seconds";
    final val = extractSgValue(data['swellPeriod']);
    if (val == null) return "8 seconds";
    return "${val.toStringAsFixed(0)} seconds";
  }

  double? extractSgValue(dynamic field) {
    if (field == null) return null;
    if (field is num) return field.toDouble();
    if (field is Map) {
      for (var val in field.values) {
        if (val is num) return val.toDouble();
      }
    }
    return null;
  }

  Map<String, dynamic>? getForecastEntry(String dayLabel, String period) {
    final hours = weatherData.value?['hours'] as List?;
    if (hours == null || hours.isEmpty) return null;

    DateTime targetDate = DateTime.now();
    if (dayLabel != "Today") {
      final List<String> weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      for (var item in hours) {
        final timeStr = item['time'] as String?;
        if (timeStr == null) continue;
        try {
          final dt = DateTime.parse(timeStr).toLocal();
          final label = "${weekdays[dt.weekday % 7]} ${dt.day}";
          if (label == dayLabel) {
            targetDate = dt;
            break;
          }
        } catch (_) {}
      }
    }

    int targetHour = 9;
    if (period == "Afternoon") targetHour = 15;
    if (period == "Evening") targetHour = 20;

    Map<String, dynamic>? bestMatch;
    double minDiff = double.infinity;

    for (var item in hours) {
      final timeStr = item['time'] as String?;
      if (timeStr == null) continue;
      try {
        final dt = DateTime.parse(timeStr).toLocal();
        final diff = DateTime(dt.year, dt.month, dt.day, dt.hour)
            .difference(DateTime(targetDate.year, targetDate.month, targetDate.day, targetHour))
            .inHours
            .abs();
        if (diff < minDiff) {
          minDiff = diff.toDouble();
          bestMatch = item as Map<String, dynamic>?;
        }
      } catch (_) {}
    }

    return bestMatch;
  }

  void toggleOfflineZone(MapZoneModel zone) async {
    final name = zone.name;
    if (offlineZones.contains(name)) {
      Get.defaultDialog(
        title: "Remove Offline Cache",
        middleText: "Are you sure you want to remove the offline cache for $name?",
        textConfirm: "Remove",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () async {
          Get.back(); // close dialog
          EasyLoading.show(status: "Removing...");
          await _removeOfflineZone(zone);
          EasyLoading.showSuccess("Offline data removed");
        },
      );
    } else {
      // Check connectivity using SyncService
      bool online = false;
      try {
        final syncService = Get.find<SyncService>();
        online = syncService.isOnline.value;
      } catch (_) {}

      if (!online) {
        Get.snackbar(
          "Connection Required",
          "You must be online to download offline data for $name.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      isDownloadingZone.value = true;
      downloadingZoneName.value = name;
      try {
        await _downloadOfflineZone(zone);
        EasyLoading.showSuccess("Grid details saved offline!");
      } catch (e) {
        EasyLoading.showError("Failed to save offline: $e");
      } finally {
        isDownloadingZone.value = false;
        downloadingZoneName.value = "";
      }
    }
  }

  Future<void> _downloadOfflineZone(MapZoneModel zone) async {
    // Fetch and save with a custom long TTL (e.g. 52560000 minutes = 100 years)
    final longTtl = 52560000;
    
    await Future.wait([
      fetchReports(customTtl: longTtl),
      fetchSummary(customTtl: longTtl),
      fetchWeather(customTtl: longTtl),
    ]);

    if (!offlineZones.contains(zone.name)) {
      offlineZones.add(zone.name);
    }
    await StorageService.saveOfflineZones(offlineZones.toList());
  }

  Future<void> _removeOfflineZone(MapZoneModel zone) async {
    final cacheService = Get.find<OfflineCacheService>();
    final lat = zone.location.latitude;
    final lng = zone.location.longitude;

    // Delete keys:
    // 1. zone_summary_${zone.name}
    final summaryKey = "zone_summary_${zone.name}";
    await cacheService.deleteCache(summaryKey);

    // 2. weather_${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}
    final weatherKey = "weather_${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}";
    await cacheService.deleteCache(weatherKey);

    offlineZones.remove(zone.name);
    await StorageService.saveOfflineZones(offlineZones.toList());
  }
}

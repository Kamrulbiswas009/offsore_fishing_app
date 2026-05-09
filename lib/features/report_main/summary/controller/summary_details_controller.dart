import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:paytonpieper/features/map/model/map_zone_model.dart';
import 'package:paytonpieper/features/report_main/report/model/report_model.dart';
import 'package:paytonpieper/features/report_main/report_catch/screen/report_catch_screen.dart';

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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is MapZoneModel) {
      selectedZone.value = Get.arguments;
    }
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
  final List<String> reportTypeList = [
    "public",
    "Group",
    "My reports",
  ];

  final List<FishingReport> reports = [
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
  ];

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
        if (!report.title.toLowerCase().contains(selectedSpecies.value.toLowerCase())) {
          return false;
        }
      }

      // 2. Depth Filter
      if (selectedDepth.isNotEmpty) {
        final cleanReportDepth = int.tryParse(report.depth.replaceAll(RegExp(r'[^0-9]'), ''));
        if (cleanReportDepth != null) {
          final range = selectedDepth.value;
          if (range == "0-50 ft" && (cleanReportDepth < 0 || cleanReportDepth > 50)) return false;
          if (range == "50-100 ft" && (cleanReportDepth < 50 || cleanReportDepth > 100)) return false;
          if (range == "100-200 ft" && (cleanReportDepth < 100 || cleanReportDepth > 200)) return false;
          if (range == "200-500 ft" && (cleanReportDepth < 200 || cleanReportDepth > 500)) return false;
          if (range == "500+ ft" && cleanReportDepth < 500) return false;
        }
      }

      // 3. Technique Filter
      if (selectedTechnique.isNotEmpty) {
        if (report.technique.toLowerCase() != selectedTechnique.value.toLowerCase()) {
          return false;
        }
      }

      // 4. Time Filter
      if (selectedTime.isNotEmpty) {
        final cleanReportHour = int.tryParse(report.timeAgo.replaceAll(RegExp(r'[^0-9]'), ''));
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
        if (report.type.toLowerCase() != selectedReportType.value.toLowerCase()) {
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

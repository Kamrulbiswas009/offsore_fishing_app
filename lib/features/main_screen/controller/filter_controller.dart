import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import '../../report_main/summary/controller/summary_details_controller.dart';
import '../../map/controller/map_screen_controller.dart';
import 'main_screen_controller.dart';

class FilterController extends GetxController {
  // Species Selection
  var selectedSpecies = <String>[].obs;
  final List<String> speciesList = speciesHierarchy.expand((node) => node.allSelectableLeafNames).toList();

  // Depth Range
  var depthValue = 250.0.obs;

  // Method Selection
  var selectedMethods = <String>[].obs;
  final List<String> methods = ["Trolling", "Bottom", "Jigging", "Live Bait"];

  // Visibility
  var selectedVisibilities = <String>["Public"].obs;

  // Time Range
  var selectedTime = "24h".obs;
  final List<String> timeRanges = ["6h", "24h", "3d", "7d"];

  void toggleSpecies(String name) {
    selectedSpecies.contains(name) ? selectedSpecies.remove(name) : selectedSpecies.add(name);
  }

  void toggleMethod(String name) {
    selectedMethods.contains(name) ? selectedMethods.remove(name) : selectedMethods.add(name);
  }

  void toggleVisibility(String name) {
    selectedVisibilities.contains(name) ? selectedVisibilities.remove(name) : selectedVisibilities.add(name);
  }

  void resetFilters() {
    selectedSpecies.clear();
    depthValue.value = 250.0;
    selectedMethods.clear();
    selectedVisibilities.assign("Public");
    selectedTime.value = "24h";
  }

  Future<void> applyFilters() async {
    await EasyLoading.show(status: 'Applying filters...');
    try {
      final network = NetworkCaller();
      var accessToken = StorageService.token;
      // Fallback to test token if token is missing
      if (accessToken == null || accessToken.isEmpty) {
        accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMDYxM2ViMC0zY2E4LTQ1MjItOTA4MC1hODM1NzFkZDdkODAiLCJlbWFpbCI6InVzZXJAZ21haWwuY29tIiwiaWF0IjoxNzgzMzAyMzM0LCJleHAiOjE3ODM5MDcxMzR9.3d1C44JOmw7aIpq6gna6kIrzXNfwVlaWkFfZxuaHYFo";
      }
      final token = 'Bearer $accessToken';

      final speciesParam = selectedSpecies.isEmpty ? null : selectedSpecies.join(',');
      final depthMin = 0;
      final depthMax = depthValue.value.toInt();

      final mappedMethods = selectedMethods.map((m) {
        final clean = m.trim().toUpperCase();
        if (clean.contains("TROLLING")) return "TROLLING";
        if (clean.contains("JIGGING")) return "JIGGING";
        if (clean.contains("BOTTOM")) return "ANCHOR_SPOT_FISHING";
        if (clean.contains("LIVE BAILT") || clean.contains("LIVE BAIT")) return "ANCHOR_SPOT_FISHING";
        return "CASTING";
      }).toList();
      final methodParam = mappedMethods.isEmpty ? null : mappedMethods.join(',');

      String? visibilityParam;
      final upperVis = selectedVisibilities.map((v) => v.trim().toUpperCase()).toList();
      if (upperVis.contains("PUBLIC") && !upperVis.contains("GROUP")) {
        visibilityParam = "PUBLIC";
      } else if (upperVis.contains("GROUP") && !upperVis.contains("PUBLIC")) {
        visibilityParam = "GROUP";
      } else if (upperVis.contains("PUBLIC") && upperVis.contains("GROUP")) {
        visibilityParam = "PUBLIC,GROUP";
      }

      final url = ApiConstants.getFilteredZoneSummaryApi(
        regionCode: "GOM",
        species: speciesParam,
        depthMinFt: depthMin,
        depthMaxFt: depthMax,
        fishingMethod: methodParam,
        visibility: visibilityParam,
        timeRange: selectedTime.value,
        page: 1,
        limit: 20,
      );

      final response = await network.getRequest(url, token: token);

      if (response.isSuccess) {
        await EasyLoading.dismiss();
        final data = response.responseData['data'];
        final overview = data != null ? data['activityOverview'] : null;
        final reportsCount = overview != null ? (overview['reportsCount'] ?? 0) : 0;
        final hitRate = overview != null ? (overview['hitRate'] ?? 0) : 0;

        // Trigger map refresh with filters
        if (Get.isRegistered<MapScreenController>()) {
          final mapController = Get.find<MapScreenController>();
          mapController.refreshMapWithFilters();
        }

        await EasyLoading.showSuccess(
          "Filters applied successfully!",
          duration: const Duration(seconds: 2),
        );
        Get.back();
      } else {
        await EasyLoading.dismiss();
        await EasyLoading.showError("Failed to apply filters: ${response.errorMessage}");
      }
    } catch (e) {
      await EasyLoading.dismiss();
      await EasyLoading.showError("An error occurred while applying filters.");
      AppLoggerHelper.error("Exception applying filters: $e");
    }
  }
}
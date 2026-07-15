import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import '../../map/controller/map_screen_controller.dart';

class FilterController extends GetxController {
  // Species Selection
  var selectedSpecies = <String>[].obs;
  final List<String> speciesList = speciesHierarchy.expand((node) => node.allSelectableLeafNames).toList();

  // Depth Range
  var depthValue = 250.0.obs;

  // Method Selection
  var selectedMethods = <String>[].obs;
  final List<String> methods = [
    "Anchor/Spot Fishing",
    "Casting",
    "Chunking",
    "Jigging",
    "Spearing",
    "Trolling",
  ];

  // Visibility
  var selectedVisibilities = <String>["Public"].obs;

  // Time Range
  var selectedTime = "24h".obs;
  final List<String> timeRanges = ["6h", "24h", "3d", "7d"];

  void toggleSpecies(String name) {
    selectedSpecies.contains(name) ? selectedSpecies.remove(name) : selectedSpecies.add(name);
  }

  bool get isAllSpeciesSelected => selectedSpecies.length == speciesList.length;

  void selectAllSpecies() {
    selectedSpecies.assignAll(speciesList);
  }

  void clearAllSpecies() {
    selectedSpecies.clear();
  }

  void toggleSelectAllSpecies() {
    if (isAllSpeciesSelected) {
      clearAllSpecies();
    } else {
      selectAllSpecies();
    }
  }

  void toggleMethod(String name) {
    selectedMethods.contains(name) ? selectedMethods.remove(name) : selectedMethods.add(name);
  }

  bool get isAllMethodsSelected => selectedMethods.length == methods.length;

  void selectAllMethods() {
    selectedMethods.assignAll(methods);
  }

  void clearAllMethods() {
    selectedMethods.clear();
  }

  void toggleSelectAllMethods() {
    if (isAllMethodsSelected) {
      clearAllMethods();
    } else {
      selectAllMethods();
    }
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
    applyFilters();
  }

  Future<void> applyFilters() async {
    await EasyLoading.show(status: 'Applying filters...');
    try {
      // Trigger map refresh with filters directly to avoid duplicate fetches and latency
      if (Get.isRegistered<MapScreenController>()) {
        final mapController = Get.find<MapScreenController>();
        await mapController.refreshMapWithFilters();
      }

      await EasyLoading.showSuccess(
        "Filters applied successfully!",
        duration: const Duration(seconds: 1),
      );
      Get.back();
    } catch (e) {
      await EasyLoading.dismiss();
      await EasyLoading.showError("An error occurred while applying filters.");
      AppLoggerHelper.error("Exception applying filters: $e");
    }
  }
}
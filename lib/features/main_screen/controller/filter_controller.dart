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
  var depthValue = 625.0.obs;

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
  var selectedVisibilities = <String>["Public", "Group"].obs;

  // Time Range
  var selectedTime = "".obs;
  final List<String> timeRanges = ["6h", "24h", "3d", "7d"];

  // Temporary state for the filter dialog UI
  var tempSelectedSpecies = <String>[].obs;
  var tempDepthValue = 625.0.obs;
  var tempSelectedMethods = <String>[].obs;
  var tempSelectedVisibilities = <String>["Public", "Group"].obs;
  var tempTimeValue = "".obs;

  void initTempFields() {
    tempSelectedSpecies.assignAll(selectedSpecies);
    tempDepthValue.value = depthValue.value;
    tempSelectedMethods.assignAll(selectedMethods);
    tempSelectedVisibilities.assignAll(selectedVisibilities);
    tempTimeValue.value = selectedTime.value;
  }

  void commitTempFilters() {
    selectedSpecies.assignAll(tempSelectedSpecies);
    depthValue.value = tempDepthValue.value;
    selectedMethods.assignAll(tempSelectedMethods);
    selectedVisibilities.assignAll(tempSelectedVisibilities);
    selectedTime.value = tempTimeValue.value;
  }

  void toggleTempSpecies(String name) {
    tempSelectedSpecies.contains(name) ? tempSelectedSpecies.remove(name) : tempSelectedSpecies.add(name);
  }

  bool get isAllTempSpeciesSelected => tempSelectedSpecies.length == speciesList.length;

  void selectAllTempSpecies() {
    tempSelectedSpecies.assignAll(speciesList);
  }

  void clearAllTempSpecies() {
    tempSelectedSpecies.clear();
  }

  void toggleSelectAllTempSpecies() {
    if (isAllTempSpeciesSelected) {
      clearAllTempSpecies();
    } else {
      selectAllTempSpecies();
    }
  }

  void toggleTempMethod(String name) {
    tempSelectedMethods.contains(name) ? tempSelectedMethods.remove(name) : tempSelectedMethods.add(name);
  }

  bool get isAllTempMethodsSelected => tempSelectedMethods.length == methods.length;

  void selectAllTempMethods() {
    tempSelectedMethods.assignAll(methods);
  }

  void clearAllTempMethods() {
    tempSelectedMethods.clear();
  }

  void toggleSelectAllTempMethods() {
    if (isAllTempMethodsSelected) {
      clearAllTempMethods();
    } else {
      selectAllTempMethods();
    }
  }

  void toggleTempVisibility(String name) {
    tempSelectedVisibilities.contains(name) ? tempSelectedVisibilities.remove(name) : tempSelectedVisibilities.add(name);
  }

  bool get isAllTempVisibilitiesSelected =>
      tempSelectedVisibilities.contains("Public") && tempSelectedVisibilities.contains("Group");

  void resetFilters() {
    tempSelectedSpecies.clear();
    tempDepthValue.value = 625.0;
    tempSelectedMethods.clear();
    tempSelectedVisibilities.assignAll(["Public", "Group"]);
    tempTimeValue.value = "";
    applyFilters();
  }

  /// Whether both visibilities are selected (default = no filter).
  bool get isAllVisibilitiesSelected =>
      selectedVisibilities.contains("Public") && selectedVisibilities.contains("Group");

  bool get isAllSpeciesSelected => selectedSpecies.length == speciesList.length;
  bool get isAllMethodsSelected => selectedMethods.length == methods.length;

  /// Returns the number of active filter categories (0 = no filters active).
  int get activeFilterCount {
    int count = 0;
    if (selectedSpecies.isNotEmpty && !isAllSpeciesSelected) count++;
    if (depthValue.value != 625.0) count++;
    if (selectedMethods.isNotEmpty && !isAllMethodsSelected) count++;
    if (!isAllVisibilitiesSelected) count++;
    if (selectedTime.value.isNotEmpty) count++;
    return count;
  }

  Future<void> applyFilters() async {
    commitTempFilters();
    await EasyLoading.show(status: 'Applying filters...');
    try {
      // Trigger map refresh with filters directly to avoid duplicate fetches and latency
      if (Get.isRegistered<MapScreenController>()) {
        final mapController = Get.find<MapScreenController>();
        await mapController.refreshMapWithFilters();
      }

      final count = activeFilterCount;
      await EasyLoading.showSuccess(
        count > 0
            ? "$count filter${count > 1 ? 's' : ''} applied!"
            : "Showing all data",
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
import 'package:get/get.dart';

class FilterController extends GetxController {
  // Species Selection
  var selectedSpecies = <String>[].obs;
  final List<String> speciesList = ["Tuna", "Snapper", "Grouper", "Mahi", "Wahoo", "Marlin"];

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
}
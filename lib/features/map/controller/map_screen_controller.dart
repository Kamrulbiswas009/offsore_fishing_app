import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../model/map_zone_model.dart';

class MapScreenController extends GetxController {
  // Center of the map (Example: Miami Coast)
  final LatLng mapCenter = const LatLng(25.7617, -80.1918);
  
  // Observable list of active zones
  var activeZones = <MapZoneModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void loadMockData() {
    activeZones.assignAll([
      MapZoneModel(id: "1", location: const LatLng(25.7617, -80.1918), count: 12, level: ActivityLevel.high),
      MapZoneModel(id: "2", location: const LatLng(25.7700, -80.2100), count: 8, level: ActivityLevel.high),
      MapZoneModel(id: "3", location: const LatLng(25.7500, -80.1800), count: 3, level: ActivityLevel.medium),
      MapZoneModel(id: "4", location: const LatLng(25.7800, -80.1700), count: 6, level: ActivityLevel.low),
    ]);
  }
}
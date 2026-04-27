import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../model/map_zone_model.dart';

class MapScreenController extends GetxController {
  // Center of the map (Gulf of Mexico – offshore)
  final LatLng mapCenter = const LatLng(28.5, -88.5);

  // Observable list of active zones
  var activeZones = <MapZoneModel>[].obs;

  // Currently selected zone (null = none selected)
  var selectedZone = Rxn<MapZoneModel>();

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  void selectZone(MapZoneModel zone) {
    selectedZone.value = zone;
  }

  void deselectZone() {
    selectedZone.value = null;
  }

  void loadMockData() {
    activeZones.assignAll([
      const MapZoneModel(
        id: '1',
        name: 'GOM-12',
        location: LatLng(28.55, -88.45),
        count: 12,
        level: ActivityLevel.high,
        reports: 24,
        lastUpdated: '6 hours ago',
        activityScore: 0.92,
        topSpecies: 'Tuna',
        avgDepth: '120 ft',
        trend: TrendDirection.rising,
      ),
      const MapZoneModel(
        id: '2',
        name: 'GOM-8',
        location: LatLng(28.62, -88.60),
        count: 8,
        level: ActivityLevel.high,
        reports: 17,
        lastUpdated: '2 hours ago',
        activityScore: 0.78,
        topSpecies: 'Marlin',
        avgDepth: '95 ft',
        trend: TrendDirection.stable,
      ),
      const MapZoneModel(
        id: '3',
        name: 'GOM-3',
        location: LatLng(28.48, -88.52),
        count: 3,
        level: ActivityLevel.medium,
        reports: 6,
        lastUpdated: '1 day ago',
        activityScore: 0.35,
        topSpecies: 'Snapper',
        avgDepth: '60 ft',
        trend: TrendDirection.falling,
      ),
      // const MapZoneModel(
      //   id: '4',
      //   name: 'GOM-6',
      //   location: LatLng(28.58, -88.38),
      //   count: 6,
      //   level: ActivityLevel.low,
      //   reports: 11,
      //   lastUpdated: '3 hours ago',
      //   activityScore: 0.55,
      //   topSpecies: 'Grouper',
      //   avgDepth: '80 ft',
      //   trend: TrendDirection.rising,
      // ),
      const MapZoneModel(
        id: '5',
        name: 'GOM-1',
        location: LatLng(28.45, -88.42),
        count: 1,
        level: ActivityLevel.low,
        reports: 3,
        lastUpdated: '5 hours ago',
        activityScore: 0.15,
        topSpecies: 'Wahoo',
        avgDepth: '140 ft',
        trend: TrendDirection.stable,
      ),
      const MapZoneModel(
        id: '6',
        name: 'GOM-7',
        location: LatLng(28.50, -88.30),
        count: 7,
        level: ActivityLevel.medium,
        reports: 14,
        lastUpdated: '30 min ago',
        activityScore: 0.68,
        topSpecies: 'Mahi',
        avgDepth: '110 ft',
        trend: TrendDirection.rising,
      ),
      const MapZoneModel(
        id: '7',
        name: 'GOM-4',
        location: LatLng(28.53, -88.22),
        count: 4,
        level: ActivityLevel.medium,
        reports: 9,
        lastUpdated: '4 hours ago',
        activityScore: 0.44,
        topSpecies: 'Sailfish',
        avgDepth: '200 ft',
        trend: TrendDirection.falling,
      ),
    ]);
  }
}

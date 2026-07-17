import 'package:get/get.dart';
import 'package:paytonpieper/core/services/weather_alert_service.dart';
import 'package:paytonpieper/features/weather_alerts/model/watched_zone_model.dart';
import 'package:paytonpieper/routes/app_routes.dart';

/// UI-facing GetX controller that bridges [WeatherAlertService] to the widget layer.
class WeatherAlertController extends GetxController {
  WeatherAlertService get _service => Get.find<WeatherAlertService>();

  /// Observable proxy list — delegates to service for truth.
  RxList<WatchedZoneConfig> get watchedZones => _service.watchedZones;

  bool isWatched(String zoneId) => _service.isWatched(zoneId);

  WatchedZoneConfig? configFor(String zoneId) => _service.configFor(zoneId);

  ZoneAlertSnapshot? lastSnapshotFor(String zoneId) =>
      _service.lastSnapshotFor(zoneId);

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addZone(WatchedZoneConfig zone) => _service.addZone(zone);

  Future<void> removeZone(String zoneId) => _service.removeZone(zoneId);

  Future<void> updateZone(WatchedZoneConfig zone) => _service.updateZone(zone);

  Future<void> toggleAlerts(String zoneId, {required bool enabled}) =>
      _service.toggleAlerts(zoneId, enabled);

  // ── Navigation ────────────────────────────────────────────────────────────

  void openWatchedZonesScreen() =>
      Get.toNamed(AppRoute.watchedZonesScreen);
}

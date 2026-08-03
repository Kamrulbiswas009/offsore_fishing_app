import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

enum LocationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  error,
}

class UserLocationData {
  final double latitude;
  final double longitude;
  final bool isRealGps;
  final String zoneId;

  UserLocationData({
    required this.latitude,
    required this.longitude,
    required this.isRealGps,
    required this.zoneId,
  });
}

class LocationPermissionService {
  /// Default Gulf of Mexico offshore coordinates & zone ID.
  static const double defaultLat = 28.5;
  static const double defaultLng = -88.5;

  Future<bool> isLocationPermissionGranted() async {
    try {
      final currentStatus = await Permission.locationWhenInUse.status;
      return currentStatus.isGranted || currentStatus.isLimited;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  Future<LocationPermissionResult> requestLocationWhenInUse() async {
    try {
      final currentStatus = await Permission.locationWhenInUse.status;
      if (currentStatus.isGranted || currentStatus.isLimited) {
        return LocationPermissionResult.granted;
      }
      if (currentStatus.isPermanentlyDenied) {
        return LocationPermissionResult.permanentlyDenied;
      }
      if (currentStatus.isRestricted) {
        return LocationPermissionResult.restricted;
      }

      final requestedStatus = await Permission.locationWhenInUse.request();
      if (requestedStatus.isGranted || requestedStatus.isLimited) {
        return LocationPermissionResult.granted;
      }
      if (requestedStatus.isPermanentlyDenied) {
        return LocationPermissionResult.permanentlyDenied;
      }
      if (requestedStatus.isRestricted) {
        return LocationPermissionResult.restricted;
      }

      return LocationPermissionResult.denied;
    } catch (_) {
      return LocationPermissionResult.error;
    }
  }

  /// Checks if a lat/lng pair falls within the Gulf of Mexico offshore coverage area.
  static bool isWithinGulfOfMexico(double lat, double lng) {
    return lat >= 18.0 && lat <= 31.0 && lng >= -100.0 && lng <= -81.0;
  }

  /// Retrieves user's current GPS position if permission is granted.
  /// If permission is denied, restricted, location is disabled, or retrieval fails,
  /// gracefully falls back to Gulf of Mexico ocean center coordinates (28.5, -88.5).
  Future<UserLocationData> getCurrentPositionOrFallback() async {
    try {
      final isGranted = await isLocationPermissionGranted();
      if (isGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        final zoneInfo = ZoneCalculator.fromLatLng(
          position.latitude,
          position.longitude,
        );
        return UserLocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          isRealGps: true,
          zoneId: zoneInfo?.zoneId ?? "GOM-R74-C88",
        );
      }
    } catch (_) {
      // Fall through to Gulf of Mexico fallback
    }

    // Default Fallback: Gulf of Mexico ocean center
    final fallbackZone = ZoneCalculator.fromLatLng(defaultLat, defaultLng);
    return UserLocationData(
      latitude: defaultLat,
      longitude: defaultLng,
      isRealGps: false,
      zoneId: fallbackZone?.zoneId ?? "GOM-R74-C88",
    );
  }
}

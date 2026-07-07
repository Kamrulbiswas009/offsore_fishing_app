import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  error,
}

class LocationPermissionService {
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
}

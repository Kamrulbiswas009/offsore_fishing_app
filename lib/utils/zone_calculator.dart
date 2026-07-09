// lib/utils/zone_calculator.dart
//
// CRITICAL: This formula MUST match the backend exactly:
//   - prisma/seed.ts → computeZoneId()
//   - src/modules/zone/utils/zone-calculator.ts → latLngToZoneId()
//
// Do NOT modify the arithmetic without updating the backend simultaneously.

class RegionConfig {
  final String code;
  final double latMin;
  final double latMax;
  final double lngMin;
  final double lngMax;
  final double resolution;

  const RegionConfig({
    required this.code,
    required this.latMin,
    required this.latMax,
    required this.lngMin,
    required this.lngMax,
    required this.resolution,
  });

  int get cols => ((lngMax - lngMin) / resolution).round();
  int get rows => ((latMax - latMin) / resolution).round();
}

/// All seeded regions. Keep in sync with backend REGION_CONFIG.
/// When a new region is added to the backend, add it here too.
const List<RegionConfig> kRegions = [
  RegionConfig(
    code: 'GOM',
    latMin: 18.0,
    latMax: 31.0,
    lngMin: -98.0,
    lngMax: -81.0,
    resolution: 0.25,
  ),
  // Add ATL, CAR, PAC etc. here when backend seeds them
];

class ZoneInfo {
  final String zoneId;
  final String regionCode;
  final double centerLat;
  final double centerLng;
  final double boundNorth;
  final double boundSouth;
  final double boundEast;
  final double boundWest;

  const ZoneInfo({
    required this.zoneId,
    required this.regionCode,
    required this.centerLat,
    required this.centerLng,
    required this.boundNorth,
    required this.boundSouth,
    required this.boundEast,
    required this.boundWest,
  });

  /// Returns the LatLngBounds for map rendering (works with google_maps_flutter, etc.)
  /// Use boundSouth/boundNorth/boundWest/boundEast directly for map polygon drawing.
}

class ZoneCalculator {
  /// Converts a lat/lng to a ZoneInfo.
  /// Returns null if outside all known regions.
  ///
  /// This is the CANONICAL formula — mirrors latLngToZoneId() on the backend.
  static ZoneInfo? fromLatLng(double lat, double lng) {
    for (final region in kRegions) {
      if (lat >= region.latMin &&
          lat < region.latMax &&
          lng >= region.lngMin &&
          lng < region.lngMax) {
        return _computeZone(lat, lng, region);
      }
    }
    return null; // outside all seeded regions
  }

  /// Computes all zone info for a point known to be inside [region].
  static ZoneInfo _computeZone(double lat, double lng, RegionConfig region) {
    final cols = region.cols;
    final col = ((lng - region.lngMin) / region.resolution).floor();
    final row = ((lat - region.latMin) / region.resolution).floor();
    final index = row * cols + col + 1; // 1-indexed

    final zoneId = '${region.code}-${index.toString().padLeft(4, '0')}';

    // SW corner of the cell (same as seed.ts rounding — 5 decimal places)
    final cellLat = _r5(region.latMin + row * region.resolution);
    final cellLng = _r5(region.lngMin + col * region.resolution);

    return ZoneInfo(
      zoneId: zoneId,
      regionCode: region.code,
      centerLat: _r5(cellLat + region.resolution / 2),
      centerLng: _r5(cellLng + region.resolution / 2),
      boundSouth: cellLat,
      boundNorth: _r5(cellLat + region.resolution),
      boundWest: cellLng,
      boundEast: _r5(cellLng + region.resolution),
    );
  }

  /// Returns the ZoneInfo for a given zoneId string (e.g. "GOM-0042").
  /// Returns null if the zoneId format is unrecognised or region unknown.
  static ZoneInfo? fromZoneId(String zoneId) {
    final parts = zoneId.split('-');
    if (parts.length != 2) return null;

    final regionCode = parts[0];
    final index = int.tryParse(parts[1]);
    if (index == null || index < 1) return null;

    final region = kRegions.firstWhere(
      (r) => r.code == regionCode,
      orElse: () => throw ArgumentError('Unknown region: $regionCode'),
    );

    final cols = region.cols;
    final zeroIndex = index - 1; // back to 0-based
    final row = zeroIndex ~/ cols;
    final col = zeroIndex % cols;

    final cellLat = _r5(region.latMin + row * region.resolution);
    final cellLng = _r5(region.lngMin + col * region.resolution);

    return ZoneInfo(
      zoneId: zoneId,
      regionCode: regionCode,
      centerLat: _r5(cellLat + region.resolution / 2),
      centerLng: _r5(cellLng + region.resolution / 2),
      boundSouth: cellLat,
      boundNorth: _r5(cellLat + region.resolution),
      boundWest: cellLng,
      boundEast: _r5(cellLng + region.resolution),
    );
  }

  /// Returns all zones overlapping a viewport bounding box.
  /// Use this for map rendering — avoids a network call to GET /zones.
  static List<ZoneInfo> zonesInBounds({
    required double south,
    required double north,
    required double west,
    required double east,
  }) {
    final results = <ZoneInfo>[];

    for (final region in kRegions) {
      // Clamp to region
      final latFrom = south.clamp(region.latMin, region.latMax);
      final latTo   = north.clamp(region.latMin, region.latMax);
      final lngFrom = west.clamp(region.lngMin, region.lngMax);
      final lngTo   = east.clamp(region.lngMin, region.lngMax);

      if (latFrom >= latTo || lngFrom >= lngTo) continue;

      // Snap to grid cell starts
      final startRow = ((latFrom - region.latMin) / region.resolution).floor();
      final endRow   = ((latTo   - region.latMin) / region.resolution).ceil();
      final startCol = ((lngFrom - region.lngMin) / region.resolution).floor();
      final endCol   = ((lngTo   - region.lngMin) / region.resolution).ceil();

      for (int row = startRow; row < endRow && row < region.rows; row++) {
        for (int col = startCol; col < endCol && col < region.cols; col++) {
          final cellLat = _r5(region.latMin + row * region.resolution);
          final cellLng = _r5(region.lngMin + col * region.resolution);
          final index = row * region.cols + col + 1;
          final zoneId = '${region.code}-${index.toString().padLeft(4, '0')}';

          results.add(ZoneInfo(
            zoneId: zoneId,
            regionCode: region.code,
            centerLat: _r5(cellLat + region.resolution / 2),
            centerLng: _r5(cellLng + region.resolution / 2),
            boundSouth: cellLat,
            boundNorth: _r5(cellLat + region.resolution),
            boundWest: cellLng,
            boundEast: _r5(cellLng + region.resolution),
          ));
        }
      }
    }
    return results;
  }

  // ── Rounding helper ────────────────────────────────────────────────────
  // Matches seed.ts: Math.round(x * 100000) / 100000
  static double _r5(double v) => (v * 100000).round() / 100000;
}

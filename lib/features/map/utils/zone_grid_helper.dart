import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Converts statute miles → degrees of latitude (constant everywhere).
double _milesToDegreesLat(double miles) => miles / 69.0;

/// Converts statute miles → degrees of longitude at a given latitude.
double _milesToDegreesLng(double miles, double latDegrees) {
  final latRad = latDegrees * math.pi / 180.0;
  return miles / (69.0 * math.cos(latRad));
}

/// A single 8×8-mile cell in the geo-anchored grid.
class GridCell {
  final String id;
  final int row;
  final int col;
  final LatLng centroid;
  final LatLng sw;
  final LatLng ne;

  const GridCell({
    required this.id,
    required this.row,
    required this.col,
    required this.centroid,
    required this.sw,
    required this.ne,
  });
}

/// Infinite geo-anchored grid of [cellMiles]×[cellMiles] cells.
///
/// The grid has no hard row/col limit — it generates cells on-demand for
/// whatever viewport bounds the caller supplies.  This makes the whole map
/// covered with partitions regardless of zoom or pan position.
class ZoneGridHelper {
  /// Fixed south-west origin of the grid (pinned to earth coordinates).
  final LatLng origin;

  /// Size of each square cell in statute miles.
  final double cellMiles;

  const ZoneGridHelper({
    required this.origin,
    this.cellMiles = 8.0,
  });

  // ── Degree deltas ────────────────────────────────────────────────────────

  double get _dLat => _milesToDegreesLat(cellMiles);
  double get _dLng => _milesToDegreesLng(cellMiles, origin.latitude);

  // ── Cell builders ────────────────────────────────────────────────────────

  /// Returns the [GridCell] for a given row/column index (may be negative).
  GridCell cellAt(int row, int col) {
    final swLat = origin.latitude + row * _dLat;
    final swLng = origin.longitude + col * _dLng;
    final neLat = swLat + _dLat;
    final neLng = swLng + _dLng;

    return GridCell(
      id: 'r${row}_c$col',
      row: row,
      col: col,
      sw: LatLng(swLat, swLng),
      ne: LatLng(neLat, neLng),
      centroid: LatLng((swLat + neLat) / 2, (swLng + neLng) / 2),
    );
  }

  /// Returns all cells that overlap the given geographic bounds, plus
  /// [buffer] extra cells on every side (so edges never appear empty).
  ///
  /// Capped at 3600 cells per call to stay performant.
  List<GridCell> cellsForBounds(
    LatLng sw,
    LatLng ne, {
    int buffer = 2,
  }) {
    final minRow =
        ((sw.latitude - origin.latitude) / _dLat).floor() - buffer;
    final maxRow =
        ((ne.latitude - origin.latitude) / _dLat).ceil() + buffer;
    final minCol =
        ((sw.longitude - origin.longitude) / _dLng).floor() - buffer;
    final maxCol =
        ((ne.longitude - origin.longitude) / _dLng).ceil() + buffer;

    // Safety cap: never generate more than 3600 cells per refresh
    final rowCount = (maxRow - minRow).clamp(0, 60);
    final colCount = (maxCol - minCol).clamp(0, 60);

    final cells = <GridCell>[];
    for (var r = minRow; r <= minRow + rowCount; r++) {
      for (var c = minCol; c <= minCol + colCount; c++) {
        cells.add(cellAt(r, c));
      }
    }
    return cells;
  }

  // ── Coordinate → cell lookup ─────────────────────────────────────────────

  /// Returns the [GridCell] that contains [coord], or `null` if it cannot
  /// be determined (e.g. extremely far from origin).
  GridCell? cellForCoordinate(LatLng coord) {
    final col = ((coord.longitude - origin.longitude) / _dLng).floor();
    final row = ((coord.latitude - origin.latitude) / _dLat).floor();
    return cellAt(row, col);
  }

  // ── GeoJSON builders ─────────────────────────────────────────────────────

  /// Polygon FeatureCollection for [cells] with data-driven activity styling.
  Map<String, dynamic> buildCellGeoJson(
    List<GridCell> cells,
    Map<String, Map<String, dynamic>> activityMap,
  ) {
    return {
      'type': 'FeatureCollection',
      'features': cells
          .map((c) => _cellFeature(
                cell: c,
                level: activityMap[c.id]?['level'] as String? ?? 'empty',
                count: activityMap[c.id]?['count'] as int? ?? 0,
              ))
          .toList(),
    };
  }

  /// Point FeatureCollection for SymbolLayer labels (only active cells).
  Map<String, dynamic> buildLabelGeoJson(
    List<GridCell> cells,
    Map<String, Map<String, dynamic>> activityMap,
  ) {
    final features = <Map<String, dynamic>>[];
    for (final c in cells) {
      final data = activityMap[c.id];
      final count = data?['count'] as int? ?? 0;
      if (count == 0) continue;
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [c.centroid.longitude, c.centroid.latitude],
        },
        'properties': {
          'label': count.toString(),
          'activityLevel': data?['level'] ?? 'empty',
        },
      });
    }
    return {'type': 'FeatureCollection', 'features': features};
  }

  Map<String, dynamic> _cellFeature({
    required GridCell cell,
    required String level,
    required int count,
  }) {
    final sw = cell.sw;
    final ne = cell.ne;
    return {
      'type': 'Feature',
      'id': cell.id,
      'geometry': {
        'type': 'Polygon',
        'coordinates': [
          [
            [sw.longitude, sw.latitude],
            [ne.longitude, sw.latitude],
            [ne.longitude, ne.latitude],
            [sw.longitude, ne.latitude],
            [sw.longitude, sw.latitude],
          ]
        ],
      },
      'properties': {
        'id': cell.id,
        'activityLevel': level,
        'reportCount': count,
        'label': count > 0 ? count.toString() : '',
      },
    };
  }
}

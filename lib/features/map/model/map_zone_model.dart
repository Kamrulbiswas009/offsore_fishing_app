import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ActivityLevel { high, medium, low }

enum TrendDirection { rising, stable, falling }

class MapZoneModel {
  final String id;
  final String name; // e.g. "GOM-12"
  final LatLng location;
  final int count;
  final ActivityLevel level;
  final int reports;
  final String lastUpdated;
  final double activityScore; // 0.0 – 1.0
  final String topSpecies;
  final String avgDepth;
  final TrendDirection trend;

  const MapZoneModel({
    required this.id,
    required this.name,
    required this.location,
    required this.count,
    required this.level,
    this.reports = 0,
    this.lastUpdated = 'Just now',
    this.activityScore = 0.5,
    this.topSpecies = 'Unknown',
    this.avgDepth = '—',
    this.trend = TrendDirection.stable,
  });

  Color get color {
    switch (level) {
      case ActivityLevel.high:
        return const Color(0xFFE25301);
      case ActivityLevel.medium:
        return const Color(0xFF00F0FF);
      case ActivityLevel.low:
        return const Color(0xFF516173);
    }
  }
}

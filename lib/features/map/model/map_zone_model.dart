import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum ActivityLevel { high, medium, low }

class MapZoneModel {
  final String id;
  final LatLng location;
  final int count;
  final ActivityLevel level;

  MapZoneModel({
    required this.id,
    required this.location,
    required this.count,
    required this.level,
  });

  Color get color {
    switch (level) {
      case ActivityLevel.high: return const Color(0xFFE25301);
      case ActivityLevel.medium: return const Color(0xFF00F0FF);
      case ActivityLevel.low: return const Color(0xFF516173);
    }
  }
}
// test/zone_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:paytonpieper/utils/zone_calculator.dart';

void main() {
  group('ZoneCalculator', () {
    test('GOM first cell — SW corner', () {
      final zone = ZoneCalculator.fromLatLng(18.0, -98.0);
      expect(zone!.zoneId, 'GOM-0001');
      expect(zone.boundSouth, 18.0);
      expect(zone.boundNorth, 18.25);
      expect(zone.boundWest, -98.0);
      expect(zone.boundEast, -97.75);
      expect(zone.centerLat, 18.125);
      expect(zone.centerLng, -97.875);
    });

    test('GOM — second column, first row', () {
      final zone = ZoneCalculator.fromLatLng(18.1, -97.9);
      expect(zone!.zoneId, 'GOM-0002'); // col=1, row=0 → index=2
    });

    test('GOM — second row, first column', () {
      final zone = ZoneCalculator.fromLatLng(18.3, -98.0);
      expect(zone!.zoneId, 'GOM-0069'); // col=0, row=1 → index=68+1=69
    });

    test('Outside GOM — returns null', () {
      // New York City
      expect(ZoneCalculator.fromLatLng(40.71, -74.00), isNull);
    });

    test('GOM northern boundary — outside', () {
      // Exactly at latMax is outside
      expect(ZoneCalculator.fromLatLng(31.0, -90.0), isNull);
    });

    test('fromZoneId round-trips with fromLatLng', () {
      final original = ZoneCalculator.fromLatLng(25.5, -90.0);
      final roundTrip = ZoneCalculator.fromZoneId(original!.zoneId);
      expect(roundTrip!.zoneId, original.zoneId);
      expect(roundTrip.centerLat, original.centerLat);
      expect(roundTrip.centerLng, original.centerLng);
    });

    test('zonesInBounds returns correct count for small viewport', () {
      // 2x2 cells viewport
      final zones = ZoneCalculator.zonesInBounds(
        south: 25.0,
        north: 25.5,
        west: -90.0,
        east: -89.5,
      );
      expect(zones.length, 4); // 2 rows × 2 cols
    });
  });
}

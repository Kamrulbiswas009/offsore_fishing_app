import 'dart:convert';

/// Holds the user-configured watch settings for a single zone.
class WatchedZoneConfig {
  final String zoneId; // e.g. "GOM-R74-C88"
  final String zoneName; // display label
  final double lat;
  final double lng;
  final bool alertsEnabled;

  // --- Thresholds ---
  /// Alert fires when wave height crosses this value (feet).
  final double waveHeightThresholdFt;

  /// Alert fires when wind speed crosses this value (mph).
  final double windSpeedThresholdMph;

  /// Alert fires when water temperature changes by more than this value (°F).
  final double waterTempChangeDeltaF;

  // --- Weather Conditions Alert Flags ---
  final bool alertOnThunderstorm;
  final bool alertOnRain;
  final bool alertOnGoodSunny;

  const WatchedZoneConfig({
    required this.zoneId,
    required this.zoneName,
    required this.lat,
    required this.lng,
    this.alertsEnabled = true,
    this.waveHeightThresholdFt = 4.0,
    this.windSpeedThresholdMph = 20.0,
    this.waterTempChangeDeltaF = 5.0,
    this.alertOnThunderstorm = true,
    this.alertOnRain = true,
    this.alertOnGoodSunny = true,
  });

  WatchedZoneConfig copyWith({
    String? zoneId,
    String? zoneName,
    double? lat,
    double? lng,
    bool? alertsEnabled,
    double? waveHeightThresholdFt,
    double? windSpeedThresholdMph,
    double? waterTempChangeDeltaF,
    bool? alertOnThunderstorm,
    bool? alertOnRain,
    bool? alertOnGoodSunny,
  }) {
    return WatchedZoneConfig(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      waveHeightThresholdFt:
          waveHeightThresholdFt ?? this.waveHeightThresholdFt,
      windSpeedThresholdMph:
          windSpeedThresholdMph ?? this.windSpeedThresholdMph,
      waterTempChangeDeltaF:
          waterTempChangeDeltaF ?? this.waterTempChangeDeltaF,
      alertOnThunderstorm: alertOnThunderstorm ?? this.alertOnThunderstorm,
      alertOnRain: alertOnRain ?? this.alertOnRain,
      alertOnGoodSunny: alertOnGoodSunny ?? this.alertOnGoodSunny,
    );
  }

  Map<String, dynamic> toJson() => {
    'zoneId': zoneId,
    'zoneName': zoneName,
    'lat': lat,
    'lng': lng,
    'alertsEnabled': alertsEnabled,
    'waveHeightThresholdFt': waveHeightThresholdFt,
    'windSpeedThresholdMph': windSpeedThresholdMph,
    'waterTempChangeDeltaF': waterTempChangeDeltaF,
    'alertOnThunderstorm': alertOnThunderstorm,
    'alertOnRain': alertOnRain,
    'alertOnGoodSunny': alertOnGoodSunny,
  };

  factory WatchedZoneConfig.fromJson(Map<String, dynamic> json) =>
      WatchedZoneConfig(
        zoneId: json['zoneId'] as String? ?? '',
        zoneName: json['zoneName'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 28.375,
        lng: (json['lng'] as num?)?.toDouble() ?? -89.125,
        alertsEnabled: json['alertsEnabled'] as bool? ?? true,
        waveHeightThresholdFt:
            (json['waveHeightThresholdFt'] as num?)?.toDouble() ?? 4.0,
        windSpeedThresholdMph:
            (json['windSpeedThresholdMph'] as num?)?.toDouble() ?? 20.0,
        waterTempChangeDeltaF:
            (json['waterTempChangeDeltaF'] as num?)?.toDouble() ?? 5.0,
        alertOnThunderstorm: json['alertOnThunderstorm'] as bool? ?? true,
        alertOnRain: json['alertOnRain'] as bool? ?? true,
        alertOnGoodSunny: json['alertOnGoodSunny'] as bool? ?? true,
      );

  /// Serialize a list of configs to a JSON string for SharedPreferences.
  static String encodeList(List<WatchedZoneConfig> list) =>
      jsonEncode(list.map((z) => z.toJson()).toList());

  /// Deserialize a JSON string from SharedPreferences.
  static List<WatchedZoneConfig> decodeList(String raw) {
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(WatchedZoneConfig.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  String toString() =>
      'WatchedZoneConfig(zoneId: $zoneId, alertsEnabled: $alertsEnabled)';
}

/// Snapshot of last-alerted weather condition state per zone.
class ZoneAlertSnapshot {
  /// Bucketed condition hash used to detect meaningful changes.
  final String conditionHash;

  /// UTC timestamp of the last alert sent.
  final DateTime lastAlertAt;

  const ZoneAlertSnapshot({
    required this.conditionHash,
    required this.lastAlertAt,
  });

  Map<String, dynamic> toJson() => {
    'conditionHash': conditionHash,
    'lastAlertAt': lastAlertAt.toIso8601String(),
  };

  factory ZoneAlertSnapshot.fromJson(Map<String, dynamic> json) =>
      ZoneAlertSnapshot(
        conditionHash: json['conditionHash'] as String? ?? '',
        lastAlertAt:
            DateTime.tryParse(json['lastAlertAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  /// Serialize a map of zoneId → snapshot to a JSON string.
  static String encodeMap(Map<String, ZoneAlertSnapshot> map) =>
      jsonEncode(map.map((k, v) => MapEntry(k, v.toJson())));

  /// Deserialize a JSON string.
  static Map<String, ZoneAlertSnapshot> decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(
          k,
          ZoneAlertSnapshot.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
      );
    } catch (_) {
      return {};
    }
  }
}

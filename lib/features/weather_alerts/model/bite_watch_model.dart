class BiteWatchModel {
  final String watchId;
  final String zoneId;
  final String displayLabel;
  final double? centerLat;
  final double? centerLng;
  final double? activityScore;
  final String? trendDirection;
  final int? reportCount;
  final bool watchBiteActivity;
  final int biteThreshold;
  final int biteThresholdDays;
  final DateTime? lastNotifiedAt;

  BiteWatchModel({
    required this.watchId,
    required this.zoneId,
    required this.displayLabel,
    this.centerLat,
    this.centerLng,
    this.activityScore,
    this.trendDirection,
    this.reportCount,
    this.watchBiteActivity = true,
    this.biteThreshold = 3,
    this.biteThresholdDays = 7,
    this.lastNotifiedAt,
  });

  BiteWatchModel copyWith({
    String? watchId,
    String? zoneId,
    String? displayLabel,
    double? centerLat,
    double? centerLng,
    double? activityScore,
    String? trendDirection,
    int? reportCount,
    bool? watchBiteActivity,
    int? biteThreshold,
    int? biteThresholdDays,
    DateTime? lastNotifiedAt,
  }) {
    return BiteWatchModel(
      watchId: watchId ?? this.watchId,
      zoneId: zoneId ?? this.zoneId,
      displayLabel: displayLabel ?? this.displayLabel,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      activityScore: activityScore ?? this.activityScore,
      trendDirection: trendDirection ?? this.trendDirection,
      reportCount: reportCount ?? this.reportCount,
      watchBiteActivity: watchBiteActivity ?? this.watchBiteActivity,
      biteThreshold: biteThreshold ?? this.biteThreshold,
      biteThresholdDays: biteThresholdDays ?? this.biteThresholdDays,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
    );
  }

  factory BiteWatchModel.fromJson(Map<String, dynamic> json) {
    // Backend can return 'id' or 'watchId'
    final id = (json['watchId'] ?? json['id'] ?? '').toString();
    final zoneId = (json['zoneId'] ?? '').toString();
    final label = (json['displayLabel'] ?? json['zoneId'] ?? '').toString();
    
    DateTime? notifiedAt;
    if (json['lastNotifiedAt'] != null) {
      notifiedAt = DateTime.tryParse(json['lastNotifiedAt'].toString());
    }

    return BiteWatchModel(
      watchId: id,
      zoneId: zoneId,
      displayLabel: label,
      centerLat: (json['centerLat'] as num?)?.toDouble(),
      centerLng: (json['centerLng'] as num?)?.toDouble(),
      activityScore: (json['activityScore'] as num?)?.toDouble(),
      trendDirection: json['trendDirection']?.toString(),
      reportCount: (json['reportCount'] as num?)?.toInt(),
      watchBiteActivity: json['watchBiteActivity'] as bool? ?? true,
      biteThreshold: (json['biteThreshold'] as num?)?.toInt() ?? 3,
      biteThresholdDays: (json['biteThresholdDays'] as num?)?.toInt() ?? 7,
      lastNotifiedAt: notifiedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'watchId': watchId,
    'zoneId': zoneId,
    'displayLabel': displayLabel,
    'centerLat': centerLat,
    'centerLng': centerLng,
    'activityScore': activityScore,
    'trendDirection': trendDirection,
    'reportCount': reportCount,
    'watchBiteActivity': watchBiteActivity,
    'biteThreshold': biteThreshold,
    'biteThresholdDays': biteThresholdDays,
    'lastNotifiedAt': lastNotifiedAt?.toIso8601String(),
  };
}

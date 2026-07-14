class ProfileStatDataModel {
  final int reportsSubmitted;
  final int confirmedReports;
  final int confirmationsReceived;

  const ProfileStatDataModel({
    required this.reportsSubmitted,
    required this.confirmedReports,
    required this.confirmationsReceived,
  });

  factory ProfileStatDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatDataModel(
      reportsSubmitted: _toInt(json['reportsSubmitted']),
      confirmedReports: _toInt(json['confirmedReports']),
      confirmationsReceived: _toInt(json['confirmationsReceived']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

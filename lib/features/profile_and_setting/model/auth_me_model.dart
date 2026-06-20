class AuthMeModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? profileImage;
  final String provider;
  final String? providerId;
  final DateTime? otpExpiredAt;
  final bool isVerified;
  final bool isActive;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime? lastActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuthMeModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.profileImage,
    required this.provider,
    required this.providerId,
    required this.otpExpiredAt,
    required this.isVerified,
    required this.isActive,
    required this.isDeleted,
    required this.deletedAt,
    required this.lastActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthMeModel.fromJson(Map<String, dynamic> json) {
    return AuthMeModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      provider: json['provider'] as String? ?? '',
      providerId: json['providerId'] as String?,
      otpExpiredAt: _parseDate(json['otpExpiredAt']),
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: _parseDate(json['deletedAt']),
      lastActive: _parseDate(json['lastActive']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    return value is String ? DateTime.tryParse(value) : null;
  }
}

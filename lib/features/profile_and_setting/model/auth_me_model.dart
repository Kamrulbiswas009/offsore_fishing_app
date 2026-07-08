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
  final UserSubscriptionModel? subscription;

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
    required this.subscription,
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
      subscription: json['subscription'] is Map
          ? UserSubscriptionModel.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map),
            )
          : null,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    return value is String ? DateTime.tryParse(value) : null;
  }
}

class UserSubscriptionModel {
  final String id;
  final String userId;
  final String stripeCustomerId;
  final String stripeSubscriptionId;
  final String stripePriceId;
  final String plan;
  final String status;
  final bool cancelAtPeriodEnd;

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.stripeCustomerId,
    required this.stripeSubscriptionId,
    required this.stripePriceId,
    required this.plan,
    required this.status,
    required this.cancelAtPeriodEnd,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      stripeCustomerId: json['stripeCustomerId'] as String? ?? '',
      stripeSubscriptionId: json['stripeSubscriptionId'] as String? ?? '',
      stripePriceId: json['stripePriceId'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      status: json['status'] as String? ?? '',
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
    );
  }
}

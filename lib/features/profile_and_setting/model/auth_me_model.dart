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
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return value > 10000000000
          ? DateTime.fromMillisecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is num) {
      final intVal = value.toInt();
      return intVal > 10000000000
          ? DateTime.fromMillisecondsSinceEpoch(intVal)
          : DateTime.fromMillisecondsSinceEpoch(intVal * 1000);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
      final asInt = int.tryParse(value);
      if (asInt != null) {
        return asInt > 10000000000
            ? DateTime.fromMillisecondsSinceEpoch(asInt)
            : DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'role': role,
        'status': status,
        'profileImage': profileImage,
        'provider': provider,
        'providerId': providerId,
        'otpExpiredAt': otpExpiredAt?.toIso8601String(),
        'isVerified': isVerified,
        'isActive': isActive,
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'lastActive': lastActive?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'subscription': subscription?.toJson(),
      };

  AuthMeModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    String? status,
    String? profileImage,
    String? provider,
    String? providerId,
    DateTime? otpExpiredAt,
    bool? isVerified,
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? lastActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSubscriptionModel? subscription,
  }) {
    return AuthMeModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      otpExpiredAt: otpExpiredAt ?? this.otpExpiredAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscription: subscription ?? this.subscription,
    );
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
  final bool isPro;
  final DateTime? currentPeriodEnd;

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.stripeCustomerId,
    required this.stripeSubscriptionId,
    required this.stripePriceId,
    required this.plan,
    required this.status,
    required this.cancelAtPeriodEnd,
    required this.isPro,
    required this.currentPeriodEnd,
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
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ??
          json['cancel_at_period_end'] as bool? ??
          false,
      isPro: json['isPro'] as bool? ?? json['is_pro'] as bool? ?? false,
      currentPeriodEnd: AuthMeModel._parseDate(
        json['currentPeriodEnd'] ?? json['current_period_end'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'stripeCustomerId': stripeCustomerId,
        'stripeSubscriptionId': stripeSubscriptionId,
        'stripePriceId': stripePriceId,
        'plan': plan,
        'status': status,
        'cancelAtPeriodEnd': cancelAtPeriodEnd,
        'isPro': isPro,
        'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
      };
}

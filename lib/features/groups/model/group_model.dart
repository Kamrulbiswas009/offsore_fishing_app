// ─────────────────────────────────────────
// Model: Group List Item  (fetchGroupListApi)
// ─────────────────────────────────────────

class GroupListMember {
  final String role;
  final bool isMuted;
  final String? lastReadAt;

  const GroupListMember({
    required this.role,
    required this.isMuted,
    this.lastReadAt,
  });

  factory GroupListMember.fromJson(Map<String, dynamic> json) {
    return GroupListMember(
      role: (json['role'] as String?) ?? '',
      isMuted: (json['isMuted'] as bool?) ?? false,
      lastReadAt: json['lastReadAt'] as String?,
    );
  }
}

class GroupCount {
  final int members;

  const GroupCount({required this.members});

  factory GroupCount.fromJson(Map<String, dynamic> json) {
    return GroupCount(
      members: (json['members'] as num?)?.toInt() ?? 0,
    );
  }
}

class GroupListItem {
  final String groupId;
  final String name;
  final String description;
  final String createdBy;
  final String inviteCode;
  final bool isPrivate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final List<GroupListMember> members;
  final GroupCount count;

  const GroupListItem({
    required this.groupId,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.inviteCode,
    required this.isPrivate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.count,
  });

  factory GroupListItem.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    final rawCount = json['_count'] as Map<String, dynamic>? ?? {};

    return GroupListItem(
      groupId: (json['groupId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      createdBy: (json['createdBy'] as String?) ?? '',
      inviteCode: (json['inviteCode'] as String?) ?? '',
      isPrivate: (json['isPrivate'] as bool?) ?? true,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: (json['createdAt'] as String?) ?? '',
      updatedAt: (json['updatedAt'] as String?) ?? '',
      members: rawMembers
          .map((e) => GroupListMember.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      count: GroupCount.fromJson(rawCount),
    );
  }
}

// ─────────────────────────────────────────
// Model: Single Group Details (fetchSingleGroupDetailsApi)
// ─────────────────────────────────────────

class GroupDetailUser {
  final String userId;
  final String name;
  final String email;
  final String? profileImage;

  const GroupDetailUser({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory GroupDetailUser.fromJson(Map<String, dynamic> json) {
    return GroupDetailUser(
      userId: (json['userId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      profileImage: json['profileImage'] as String?,
    );
  }
}

class GroupDetailMember {
  final String id;
  final String groupId;
  final String userId;
  final String role;
  final String status;
  final String joinedAt;
  final String? lastReadAt;
  final bool isMuted;
  final String? mutedUntil;
  final String createdAt;
  final String updatedAt;
  final GroupDetailUser user;

  const GroupDetailMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastReadAt,
    required this.isMuted,
    this.mutedUntil,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory GroupDetailMember.fromJson(Map<String, dynamic> json) {
    return GroupDetailMember(
      id: (json['id'] as String?) ?? '',
      groupId: (json['groupId'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      joinedAt: (json['joinedAt'] as String?) ?? '',
      lastReadAt: json['lastReadAt'] as String?,
      isMuted: (json['isMuted'] as bool?) ?? false,
      mutedUntil: json['mutedUntil'] as String?,
      createdAt: (json['createdAt'] as String?) ?? '',
      updatedAt: (json['updatedAt'] as String?) ?? '',
      user: GroupDetailUser.fromJson(
        Map<String, dynamic>.from((json['user'] as Map?) ?? {}),
      ),
    );
  }
}

class GroupDetailModel {
  final String groupId;
  final String name;
  final String description;
  final String createdBy;
  final String inviteCode;
  final bool isPrivate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final List<GroupDetailMember> members;

  const GroupDetailModel({
    required this.groupId,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.inviteCode,
    required this.isPrivate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    return GroupDetailModel(
      groupId: (json['groupId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      createdBy: (json['createdBy'] as String?) ?? '',
      inviteCode: (json['inviteCode'] as String?) ?? '',
      isPrivate: (json['isPrivate'] as bool?) ?? true,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: (json['createdAt'] as String?) ?? '',
      updatedAt: (json['updatedAt'] as String?) ?? '',
      members: rawMembers
          .map((e) => GroupDetailMember.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  /// Returns the name of the member whose role is OWNER.
  String get ownerName {
    try {
      return members.firstWhere((m) => m.role == 'OWNER').user.name;
    } catch (_) {
      return '';
    }
  }
}

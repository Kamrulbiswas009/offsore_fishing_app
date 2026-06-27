class GroupInvitationGroup {
  final String groupId;
  final String name;
  final String description;

  const GroupInvitationGroup({
    required this.groupId,
    required this.name,
    required this.description,
  });

  factory GroupInvitationGroup.fromJson(Map<String, dynamic> json) {
    return GroupInvitationGroup(
      groupId: (json['groupId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }
}

class GroupInvitationSender {
  final String name;
  final String email;
  final String? profileImage;

  const GroupInvitationSender({
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory GroupInvitationSender.fromJson(Map<String, dynamic> json) {
    return GroupInvitationSender(
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      profileImage: json['profileImage'] as String?,
    );
  }
}

class GroupInvitationModel {
  final String id;
  final String groupId;
  final String invitedBy;
  final String type;
  final String inviteeUserId;
  final String? inviteeEmail;
  final String? inviteCode;
  final String status;
  final String expiresAt;
  final String? acceptedAt;
  final String createdAt;
  final String updatedAt;
  final GroupInvitationGroup group;
  final GroupInvitationSender sender;

  const GroupInvitationModel({
    required this.id,
    required this.groupId,
    required this.invitedBy,
    required this.type,
    required this.inviteeUserId,
    this.inviteeEmail,
    this.inviteCode,
    required this.status,
    required this.expiresAt,
    this.acceptedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.group,
    required this.sender,
  });

  factory GroupInvitationModel.fromJson(Map<String, dynamic> json) {
    return GroupInvitationModel(
      id: (json['id'] as String?) ?? '',
      groupId: (json['groupId'] as String?) ?? '',
      invitedBy: (json['invitedBy'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      inviteeUserId: (json['inviteeUserId'] as String?) ?? '',
      inviteeEmail: json['inviteeEmail'] as String?,
      inviteCode: json['inviteCode'] as String?,
      status: (json['status'] as String?) ?? '',
      expiresAt: (json['expiresAt'] as String?) ?? '',
      acceptedAt: json['acceptedAt'] as String?,
      createdAt: (json['createdAt'] as String?) ?? '',
      updatedAt: (json['updatedAt'] as String?) ?? '',
      group: GroupInvitationGroup.fromJson(
        Map<String, dynamic>.from((json['group'] as Map?) ?? {}),
      ),
      sender: GroupInvitationSender.fromJson(
        Map<String, dynamic>.from((json['sender'] as Map?) ?? {}),
      ),
    );
  }
}

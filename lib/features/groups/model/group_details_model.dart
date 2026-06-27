class GroupReportFilterOption {
  final String label;
  final List<String> options;

  const GroupReportFilterOption({required this.label, required this.options});
}

class GroupReportItem {
  final String title;
  final String author;
  final String timeAgo;
  final String depth;
  final String technique;
  final String note;
  final int confirmations;
  final String zone;

  const GroupReportItem({
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.depth,
    required this.technique,
    required this.note,
    required this.confirmations,
    required this.zone,
  });
}

class GroupChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMine;
  final String? avatarPath;

  const GroupChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMine,
    this.avatarPath,
  });
}

class GroupMemberRequest {
  final String name;
  final String email;
  final String timeAgo;

  const GroupMemberRequest({
    required this.name,
    required this.email,
    required this.timeAgo,
  });
}

class GroupMemberItem {
  final String name;
  final String subtitle;
  final String role;
  final String avatarPath;
  final bool isLeader;

  const GroupMemberItem({
    required this.name,
    required this.subtitle,
    required this.role,
    required this.avatarPath,
    this.isLeader = false,
  });
}

class InvitableFriendItem {
  final String id;
  final String name;
  final String subtitle;
  final String avatarPath;
  final String? email;
  final String? profileImage;

  const InvitableFriendItem({
    required this.id,
    required this.name,
    this.subtitle = '',
    this.avatarPath = '',
    this.email,
    this.profileImage,
  });

  factory InvitableFriendItem.fromJson(Map<String, dynamic> json) {
    return InvitableFriendItem(
      id: (json['userId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      subtitle: (json['email'] as String?) ?? '',
      avatarPath: '',
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }
}

// ─────────────────────────────────────────
// Model: Pending Group Invite (showAllPendingInvitationOfAGroupApi)
// ─────────────────────────────────────────

class PendingGroupInviteInvitee {
  final String name;
  final String email;

  const PendingGroupInviteInvitee({
    required this.name,
    required this.email,
  });

  factory PendingGroupInviteInvitee.fromJson(Map<String, dynamic> json) {
    return PendingGroupInviteInvitee(
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }
}

class PendingGroupInviteItem {
  final String id;
  final String groupId;
  final String status;
  final PendingGroupInviteInvitee invitee;

  const PendingGroupInviteItem({
    required this.id,
    required this.groupId,
    required this.status,
    required this.invitee,
  });

  factory PendingGroupInviteItem.fromJson(Map<String, dynamic> json) {
    final rawInvitee = json['invitee'] as Map<String, dynamic>? ?? {};
    return PendingGroupInviteItem(
      id: (json['id'] as String?) ?? '',
      groupId: (json['groupId'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      invitee: PendingGroupInviteInvitee.fromJson(rawInvitee),
    );
  }
}

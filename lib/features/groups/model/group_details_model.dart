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
  final String createdBy;

  const GroupReportItem({
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.depth,
    required this.technique,
    required this.note,
    required this.confirmations,
    required this.zone,
    this.createdBy = '',
  });

  factory GroupReportItem.fromJson(Map<String, dynamic> json) {
    final speciesList = json['species'] as List?;
    final speciesNames = speciesList
        ?.map((item) {
          if (item is! Map) return null;
          return item['speciesName']?.toString();
        })
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    return GroupReportItem(
      title: speciesNames == null || speciesNames.isEmpty
          ? 'Unknown species'
          : speciesNames,
      author: _readCreatedBy(json),
      timeAgo: _formatTimeAgo(json['submittedAt']?.toString()),
      depth: '${json['waterDepthFt'] ?? 0}ft',
      technique: _formatBackendLabel(json['fishingMethod']?.toString()),
      note: json['notes']?.toString() ?? '',
      confirmations: _readConfirmations(json),
      zone:
          json['zoneId']?.toString() ??
          ((json['zone'] is Map) ? json['zone']['zoneId']?.toString() : null) ??
          'Unknown',
      createdBy: _readCreatedBy(json),
    );
  }

  static int _readConfirmations(Map<String, dynamic> json) {
    final biteConfirmations = json['biteConfirmations'];
    if (biteConfirmations is Map) {
      return (biteConfirmations['confirmed'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  static String _readCreatedBy(Map<String, dynamic> json) {
    final createdBy = json['createdBy']?.toString();
    if (createdBy != null && createdBy.isNotEmpty) return createdBy;

    final user = json['user'];
    if (user is Map) {
      final name = user['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
    }

    return 'Unknown';
  }

  static String _formatTimeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Unknown time';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.isNegative || difference.inSeconds < 60) {
        return 'just now';
      }
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      }
      if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      }
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } catch (_) {
      return 'Unknown time';
    }
  }

  static String _formatBackendLabel(String? value) {
    if (value == null || value.isEmpty) return 'Unknown';
    return value
        .split('_')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class GroupChatMessage {
  final String messageId;
  final String groupId;
  final String senderId;
  final String sender;
  final String text;
  final String time;
  final bool isMine;
  final String? avatarPath;
  final String type;
  final bool isEdited;
  final bool isDeleted;
  final String? replyToId;
  final String? replySender;
  final String? replyText;
  final DateTime? createdAt;

  const GroupChatMessage({
    this.messageId = '',
    this.groupId = '',
    this.senderId = '',
    required this.sender,
    required this.text,
    required this.time,
    required this.isMine,
    this.avatarPath,
    this.type = 'TEXT',
    this.isEdited = false,
    this.isDeleted = false,
    this.replyToId,
    this.replySender,
    this.replyText,
    this.createdAt,
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

  const PendingGroupInviteInvitee({required this.name, required this.email});

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
    final inviteeJson = Map<String, dynamic>.from(rawInvitee);
    inviteeJson['email'] ??= json['inviteeEmail'];

    return PendingGroupInviteItem(
      id: (json['id'] as String?) ?? '',
      groupId: (json['groupId'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      invitee: PendingGroupInviteInvitee.fromJson(inviteeJson),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';

enum GroupDetailsTab { reports, chat, members }

enum GroupInviteMethod { friends, code, email }

class GroupDetailsScreenController extends GetxController {
  final Rx<GroupDetailsTab> selectedTab = GroupDetailsTab.reports.obs;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController inviteEmailController = TextEditingController();
  final Rx<GroupInviteMethod> selectedInviteMethod =
      GroupInviteMethod.friends.obs;
  final RxList<String> selectedFriendIds = <String>[].obs;
  final RxBool hasInviteEmails = false.obs;

  String groupName = 'Miami Offshore Crew';
  String groupMembers = '24 members';
  String groupCreatedBy = 'Created by Captain Mike';
  String groupDescription = 'South Florida offshore fishing community';
  String groupImage = ImagePath.miamiOffShoreCrewImage;
  final String inviteCode = 'G13K7O';

  final RxList<GroupReportItem> reports = <GroupReportItem>[
    const GroupReportItem(
      title: 'Mahi Mahi',
      author: 'Captain Mike',
      timeAgo: 'about 2 hours ago',
      depth: '120ft',
      technique: 'Trolling',
      note: 'Strong bite around the weedline',
      confirmations: 3,
      zone: 'Zone Z1',
    ),
    const GroupReportItem(
      title: 'Wahoo',
      author: 'Captain Mike',
      timeAgo: 'about 2 hours ago',
      depth: '200ft',
      technique: 'Trolling',
      note: 'Strong bite around the weedline',
      confirmations: 3,
      zone: 'Zone Z1',
    ),
  ].obs;

  final RxList<GroupChatMessage> messages = <GroupChatMessage>[
    const GroupChatMessage(
      sender: 'Ralph Edwards',
      text: 'Hi',
      time: '2:34pm',
      isMine: false,
      avatarPath: ImagePath.messageProfileImage,
    ),
    const GroupChatMessage(
      sender: 'You',
      text: 'Hello..',
      time: '2:31pm',
      isMine: true,
    ),
    const GroupChatMessage(
      sender: 'You',
      text: 'How are you?',
      time: '2:31pm',
      isMine: true,
    ),
    const GroupChatMessage(
      sender: 'Ralph Edwards',
      text: 'Same reef as last time. We had good luck there with tuna.',
      time: '2:34pm',
      isMine: false,
      avatarPath: ImagePath.messageProfileImage,
    ),
    const GroupChatMessage(
      sender: 'Cameron Williamson',
      text: 'Nice! What depth are you planning to fish?',
      time: '2:35pm',
      isMine: false,
      avatarPath: ImagePath.miamiOffShoreCrewImage,
    ),
  ].obs;

  final RxList<GroupMemberRequest> pendingRequests = <GroupMemberRequest>[
    const GroupMemberRequest(
      name: 'John Smith',
      email: 'john@example.com',
      timeAgo: 'about 2 hours ago',
    ),
  ].obs;

  final RxList<GroupMemberItem> members = <GroupMemberItem>[
    const GroupMemberItem(
      name: 'Captain Mike',
      subtitle: '15 reports · Joined 3 months ago',
      role: 'ADMIN',
      avatarPath: ImagePath.miamiOffShoreCrewImage,
      isLeader: true,
    ),
    const GroupMemberItem(
      name: 'Fisher Jane',
      subtitle: '8 reports · Joined 2 months ago',
      role: 'MEMBER',
      avatarPath: ImagePath.messageProfileImage,
    ),
    const GroupMemberItem(
      name: 'Fisher Jane',
      subtitle: '8 reports · Joined 2 months ago',
      role: 'MEMBER',
      avatarPath: ImagePath.messageProfileImage,
    ),
    const GroupMemberItem(
      name: 'Fisher Jane',
      subtitle: '8 reports · Joined 2 months ago',
      role: 'MEMBER',
      avatarPath: ImagePath.messageProfileImage,
    ),
  ].obs;

  final RxList<InvitableFriendItem> invitableFriends = <InvitableFriendItem>[
    const InvitableFriendItem(
      id: 'marvin-mckinney',
      name: 'Marvin McKinney',
      subtitle: 'crew',
      avatarPath: ImagePath.miamiOffShoreCrewImage,
    ),
    const InvitableFriendItem(
      id: 'devon-lane',
      name: 'Devon Lane',
      subtitle: 'crew',
      avatarPath: ImagePath.messageProfileImage,
    ),
    const InvitableFriendItem(
      id: 'wade-warren',
      name: 'Wade Warren',
      subtitle: 'crew',
      avatarPath: ImagePath.miamiOffShoreCrewImage,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    inviteEmailController.addListener(_handleInviteEmailsChanged);
  }

  void setGroupDetails(dynamic arguments) {
    final args = Map<String, dynamic>.from(arguments ?? <String, dynamic>{});
    groupName = args['groupName'] as String? ?? 'Miami Offshore Crew';
    groupMembers = args['groupMembers'] as String? ?? '24 members';
    groupCreatedBy =
        args['groupCreatedBy'] as String? ?? 'Created by Captain Mike';
    groupDescription =
        args['groupDescription'] as String? ??
        'South Florida offshore fishing community';
    groupImage =
        args['groupImage'] as String? ?? ImagePath.miamiOffShoreCrewImage;

    final tabName = args['initialTab'] as String?;
    selectedTab.value = GroupDetailsTab.values.firstWhere(
      (tab) => tab.name == tabName,
      orElse: () => GroupDetailsTab.reports,
    );
  }

  void changeTab(GroupDetailsTab tab) {
    selectedTab.value = tab;
  }

  void selectInviteMethod(GroupInviteMethod method) {
    selectedInviteMethod.value = method;
  }

  void toggleFriendSelection(String friendId) {
    if (selectedFriendIds.contains(friendId)) {
      selectedFriendIds.remove(friendId);
      return;
    }

    selectedFriendIds.add(friendId);
  }

  bool isFriendSelected(String friendId) {
    return selectedFriendIds.contains(friendId);
  }

  void inviteSelectedFriends() {
    if (selectedFriendIds.isEmpty) {
      return;
    }

    final int invitedCount = selectedFriendIds.length;
    closeInviteMembersSheet();
    _showInviteFeedback(
      invitedCount == 1 ? '1 friend invited' : '$invitedCount friends invited',
    );
  }

  Future<void> copyInviteCode() async {
    await Clipboard.setData(ClipboardData(text: inviteCode));
    _showInviteFeedback('Invite code copied');
  }

  void sendEmailInvites() {
    final int emailCount = parsedInviteEmails.length;
    if (emailCount == 0) {
      return;
    }

    closeInviteMembersSheet();
    _showInviteFeedback(
      emailCount == 1
          ? 'Invite sent to 1 email'
          : 'Invites sent to $emailCount emails',
    );
  }

  void closeInviteMembersSheet([BuildContext? context]) {
    resetInviteMembersSheet();
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    if (Get.isOverlaysOpen) {
      Get.back();
    }
  }

  void resetInviteMembersSheet() {
    selectedInviteMethod.value = GroupInviteMethod.friends;
    selectedFriendIds.clear();
    inviteEmailController.clear();
    hasInviteEmails.value = false;
  }

  void approveRequest(GroupMemberRequest request) {
    pendingRequests.remove(request);
    members.insert(
      1,
      GroupMemberItem(
        name: request.name,
        subtitle: '0 reports · Joined just now',
        role: 'MEMBER',
        avatarPath: ImagePath.messageProfileImage,
      ),
    );
  }

  void declineRequest(GroupMemberRequest request) {
    pendingRequests.remove(request);
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messages.add(
      GroupChatMessage(sender: 'You', text: text, time: 'Now', isMine: true),
    );
    messageController.clear();
  }

  List<String> get parsedInviteEmails {
    return inviteEmailController.text
        .split(',')
        .map((email) => email.trim())
        .where((email) => email.isNotEmpty)
        .toList(growable: false);
  }

  void _handleInviteEmailsChanged() {
    hasInviteEmails.value = parsedInviteEmails.isNotEmpty;
  }

  void _showInviteFeedback(String message) {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Invite Members',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF12253B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    inviteEmailController
      ..removeListener(_handleInviteEmailsChanged)
      ..dispose();
    messageController.dispose();
    super.onClose();
  }
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

  const InvitableFriendItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarPath,
  });
}

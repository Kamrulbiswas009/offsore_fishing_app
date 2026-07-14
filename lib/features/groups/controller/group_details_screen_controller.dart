import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/groups/model/group_details_model.dart';
import 'package:paytonpieper/features/groups/model/group_model.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/models/species_node.dart';
import 'package:paytonpieper/features/groups/controller/group_main_screen_controller.dart';

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
  final RxnString selectedReportSpecies = RxnString();
  final RxnString selectedReportDepth = RxnString();
  final RxnString selectedReportMethod = RxnString();
  final RxnString selectedReportTime = RxnString();
  final RxBool isReportsLoading = false.obs;
  final RxString reportsErrorMessage = ''.obs;
  String? _lastReportFetchKey;

  final TextEditingController groupNameTEController = TextEditingController();
  final TextEditingController groupDescriptionTEController =
      TextEditingController();
  final TextEditingController searchUserTEController = TextEditingController();

  // ── API state ───────────────────────────────────────────────────────
  final Rxn<GroupDetailModel> groupDetail = Rxn<GroupDetailModel>();
  final RxBool isDetailLoading = false.obs;
  String? _groupId;

  final Rxn<File> updateGroupImage = Rxn<File>();

  Future<void> pickUpdateGroupImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        updateGroupImage.value = File(image.path);
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] pickUpdateGroupImage exception', e);
    }
  }

  String? get groupId => _groupId ?? groupDetail.value?.groupId;

  final NetworkCaller _networkCaller = NetworkCaller();

  // ── Legacy static fields (still used by existing widgets) ──────────
  String groupName = '';
  String groupMembers = '';
  String groupCreatedBy = '';
  String groupDescription = '';
  String groupImage = '';
  final RxString inviteCode = ''.obs;

  final GroupReportFilterOption speciesFilter = GroupReportFilterOption(
    label: 'Species',
    options: [
      'All Species',
      'Tuna',
      'Snapper',
      'Grouper',
      'Mahi',
      'Wahoo',
      'Marlin',
    ],
  );
  final GroupReportFilterOption depthFilter = const GroupReportFilterOption(
    label: 'Depth',
    options: [
      'All Depths',
      '0-125ft',
      '0-250ft',
      '0-375ft',
      '0-500ft',
      '0-625+ft',
    ],
  );
  final GroupReportFilterOption methodFilter = const GroupReportFilterOption(
    label: 'Method',
    options: [
      'All Methods',
      'Trolling',
      'Bottom Fishing',
      'Jigging',
      'Live Bait',
      'Chunking',
    ],
  );
  final GroupReportFilterOption timeFilter = const GroupReportFilterOption(
    label: 'Time',
    options: ['All Time', '6h', '24h', '3d', '7d'],
  );

  final RxList<GroupReportItem> reports = <GroupReportItem>[].obs;

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

  // ── Pending group invites (API) ────────────────────────────────────
  final RxList<PendingGroupInviteItem> pendingGroupInvites =
      <PendingGroupInviteItem>[].obs;

  final RxList<InvitableFriendItem> invitableFriends =
      <InvitableFriendItem>[].obs;
  final ScrollController inviteFriendsScrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isPaginationLoading = false;
  static const int _limit = 10;
  final RxString searchQuery = ''.obs;
  final RxBool isPaginationLoading = false.obs;
  String _lastSearchQuery = '';

  @override
  void onInit() {
    super.onInit();
    inviteEmailController.addListener(_handleInviteEmailsChanged);
    searchUserTEController.addListener(_handleSearchChanged);
    inviteFriendsScrollController.addListener(_scrollListener);

    debounce(searchQuery, (query) {
      final trimmed = query.trim();
      if (trimmed != _lastSearchQuery) {
        _lastSearchQuery = trimmed;
        if (trimmed.isEmpty || trimmed.length >= 2) {
          fetchUserForInvitation(isRefresh: true);
        }
      }
    }, time: const Duration(milliseconds: 500));
  }

  void _handleSearchChanged() {
    searchQuery.value = searchUserTEController.text;
  }

  void _scrollListener() {
    if (inviteFriendsScrollController.hasClients) {
      final threshold = 200.0;
      if (inviteFriendsScrollController.position.pixels >=
          inviteFriendsScrollController.position.maxScrollExtent - threshold) {
        fetchUserForInvitation(isRefresh: false);
      }
    }
  }

  Future<void> fetchUserForInvitation({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _isPaginationLoading = false;
    }

    if (!_hasMore || _isPaginationLoading) return;

    _isPaginationLoading = true;
    if (!isRefresh) {
      isPaginationLoading.value = true;
    }

    if (isRefresh) {
      await EasyLoading.show(status: 'Fetching users...');
    }

    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] fetchUserForInvitation failed: Group ID is missing',
      );
      _isPaginationLoading = false;
      isPaginationLoading.value = false;
      if (isRefresh) {
        await EasyLoading.dismiss();
      }
      return;
    }

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final queryText = searchQuery.value.trim();
      final url = ApiConstants.featchUserForInviationApi(
        queryText,
        _currentPage,
        _limit,
        id,
      );

      final response = await _networkCaller.getRequest(url, token: token);

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] fetchUserForInvitation success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawData = body is Map ? body['data'] : null;
        final rawMeta = body is Map ? body['meta'] : null;

        List<InvitableFriendItem> newUsers = [];
        if (rawData is List) {
          newUsers = rawData
              .map(
                (e) => InvitableFriendItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }

        if (isRefresh) {
          invitableFriends.assignAll(newUsers);
        } else {
          invitableFriends.addAll(newUsers);
        }

        if (rawMeta is Map) {
          final totalPages = (rawMeta['totalPages'] as num?)?.toInt() ?? 1;
          final currentPageMeta =
              (rawMeta['page'] as num?)?.toInt() ?? _currentPage;
          _currentPage = currentPageMeta + 1;
          _hasMore = currentPageMeta < totalPages;
        } else {
          if (newUsers.length < _limit) {
            _hasMore = false;
          } else {
            _currentPage++;
          }
        }
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] fetchUserForInvitation failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error(
        '[GroupDetails] fetchUserForInvitation exception',
        e,
      );
    } finally {
      _isPaginationLoading = false;
      isPaginationLoading.value = false;
      if (isRefresh) {
        await EasyLoading.dismiss();
      }
    }
  }

  // ── Fetch single group details ──────────────────────────────────────
  Future<void> fetchGroupDetails(String groupId, {bool showHUD = true, bool forceRefresh = false}) async {
    _groupId = groupId;
    groupDetail.value =
        null; // Clear previous details to avoid leaking old data
    groupName = '';
    groupMembers = '';
    groupCreatedBy = '';
    groupDescription = '';
    groupImage = '';
    isDetailLoading.value = true;
    if (showHUD) {
      await EasyLoading.show(status: 'Loading group details...');
    }

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.cachedGetRequest(
        ApiConstants.featchSingleGroupDetailsApi(groupId),
        token: token,
        cacheKey: "group_details_$groupId",
        forceRefresh: forceRefresh,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] fetchGroupDetails success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawData = body is Map ? body['data'] : null;
        if (rawData is Map) {
          final detail = GroupDetailModel.fromJson(
            Map<String, dynamic>.from(rawData),
          );
          groupDetail.value = detail;

          // Update legacy variables with server data to ensure consistency across pages
          groupName = detail.name;
          groupMembers =
              '${detail.members.length} member${detail.members.length == 1 ? '' : 's'}';
          groupCreatedBy = detail.ownerName.isNotEmpty
              ? 'Created by ${detail.ownerName}'
              : '';
          groupDescription = detail.description;
          groupImage = detail.photoUrl;

          // If the Members tab is already active and this user is the owner,
          // fetch pending invites now (fixes race where changeTab fired before
          // groupDetail was populated).
          if (selectedTab.value == GroupDetailsTab.members &&
              _isCurrentUserGroupOwner()) {
            fetchPendingGroupInvites(showHUD: showHUD);
          }
        }
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] fetchGroupDetails failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] fetchGroupDetails exception', e);
    } finally {
      isDetailLoading.value = false;
      if (showHUD) {
        await EasyLoading.dismiss();
      }
    }
  }

  void ensureReportForGroupLoaded(String? groupId) {
    final id = groupId ?? _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) return;

    final fetchKey = _buildReportFetchKey(id);
    if (_lastReportFetchKey == fetchKey || isReportsLoading.value) return;
    fetchReportForGroup(groupId: id);
  }

  Future<void> fetchReportForGroup({String? groupId}) async {
    final id = groupId ?? _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] fetchReportForGroup failed: Group ID is missing',
      );
      return;
    }

    final fetchKey = _buildReportFetchKey(id);
    _lastReportFetchKey = fetchKey;
    isReportsLoading.value = true;
    reportsErrorMessage.value = '';

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final url = ApiConstants.getReportForGroupApi(
        groupId: id,
        species: _selectedSpeciesQuery,
        timeframe: _selectedTimeQuery,
        fishingMethod: _selectedMethodQuery,
        depthMinFt: _selectedDepthRange?[0],
        depthMaxFt: _selectedDepthRange?[1],
      );

      final response = await _networkCaller.cachedGetRequest(
        url,
        token: token,
        cacheKey: "group_reports_$fetchKey",
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] fetchReportForGroup success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawData = body is Map ? body['data'] : null;
        if (rawData is List) {
          final fetchedReports = rawData
              .whereType<Map>()
              .map(
                (item) =>
                    GroupReportItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
          reports.assignAll(fetchedReports);
        } else {
          reports.clear();
        }
      } else {
        reportsErrorMessage.value = response.errorMessage;
        reports.clear();
        AppLoggerHelper.error(
          '[GroupDetails] fetchReportForGroup failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
      }
    } catch (e) {
      reportsErrorMessage.value = 'Something went wrong. Please try again.';
      reports.clear();
      AppLoggerHelper.error('[GroupDetails] fetchReportForGroup exception', e);
    } finally {
      isReportsLoading.value = false;
    }
  }

  // ── Update group details ────────────────────────────────────────────
  Future<void> updateGroup() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] updateGroup failed: Group ID is missing',
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Group ID is missing. Please reload the group.',
      );
      return;
    }

    final nameText = groupNameTEController.text.trim();
    final descriptionText = groupDescriptionTEController.text.trim();

    if (nameText.isEmpty || descriptionText.isEmpty) {
      CommonMessage.showMessage(
        title: 'Required',
        message: 'Please fill in the group name and description.',
      );
      return;
    }

    await EasyLoading.show(status: 'Updating group...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.patchMultipartRequest(
        ApiConstants.updateGroupApi(id),
        fields: {
          'name': nameText,
          'description': descriptionText,
          'isPrivate': 'true',
        },
        file: updateGroupImage.value,
        fileFieldName: 'photo',
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] updateGroup success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        // Fetch/update the group details again to refresh UI
        await fetchGroupDetails(id, forceRefresh: true);

        // Refresh group list on GroupMainScreen if registered
        if (Get.isRegistered<GroupMainScreenController>()) {
          Get.find<GroupMainScreenController>().fetchGroupList(forceRefresh: true);
        }

        // Close the dialog
        if (Get.isOverlaysOpen) {
          Get.back();
        }

        CommonMessage.showMessage(
          title: 'Success',
          message: 'Group updated successfully!',
        );
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] updateGroup failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] updateGroup exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  // ── Leave group ─────────────────────────────────────────────────────
  Future<void> leaveGroup() async {
    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] leaveGroup failed: Group ID is missing',
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Group ID is missing. Please reload the group.',
      );
      return;
    }

    await EasyLoading.show(status: 'Leaving group...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.postRequest(
        ApiConstants.leaveGroupApi(id),
        body: {},
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] leaveGroup success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        // Refresh group list on GroupMainScreen if registered
        if (Get.isRegistered<GroupMainScreenController>()) {
          Get.find<GroupMainScreenController>().fetchGroupList(forceRefresh: true);
        }

        // Close the dialog then navigate back to the previous screen
        if (Get.isOverlaysOpen) {
          Get.back(); // close dialog
        }
        Get.back(); // pop GroupDetailsScreen

        CommonMessage.showMessage(
          title: 'Success',
          message: 'You have left the group.',
        );
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] leaveGroup failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );

        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] leaveGroup exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  // ── setGroupDetails (used by GroupDetailsScreen constructor) ────────
  void setGroupDetails(dynamic arguments) {
    resetReportFilters();

    final args = Map<String, dynamic>.from(arguments ?? <String, dynamic>{});
    _groupId = args['groupId'] as String? ?? groupDetail.value?.groupId;

    // If we already have fetched details, keep them; otherwise fall back
    // to argument values (legacy path or fallback).
    groupName = args['groupName'] as String? ?? groupDetail.value?.name ?? '';
    groupMembers =
        args['groupMembers'] as String? ??
        (groupDetail.value != null
            ? '${groupDetail.value!.members.length} member${groupDetail.value!.members.length == 1 ? '' : 's'}'
            : '');
    groupCreatedBy =
        args['groupCreatedBy'] as String? ??
        (groupDetail.value?.ownerName != null &&
                groupDetail.value!.ownerName.isNotEmpty
            ? 'Created by ${groupDetail.value!.ownerName}'
            : '');
    groupDescription =
        args['groupDescription'] as String? ??
        groupDetail.value?.description ??
        '';
    groupImage =
        args['groupImage'] as String? ?? groupDetail.value?.photoUrl ?? '';

    final tabName = args['initialTab'] as String?;
    selectedTab.value = GroupDetailsTab.values.firstWhere(
      (tab) => tab.name == tabName,
      orElse: () => GroupDetailsTab.reports,
    );
  }

  void changeTab(GroupDetailsTab tab) {
    selectedTab.value = tab;
    // Auto-fetch pending invites when group owner opens the Members tab
    if (tab == GroupDetailsTab.members && _isCurrentUserGroupOwner()) {
      fetchPendingGroupInvites();
    }
  }

  /// Public getter used by the UI to check if the logged-in user is the owner.
  bool get isCurrentUserGroupOwner => _isCurrentUserGroupOwner();

  /// Returns true if the logged-in user is the group owner.
  bool _isCurrentUserGroupOwner() {
    final detail = groupDetail.value;
    if (detail == null) return false;
    final currentUserId = StorageService.userId;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return detail.createdBy == currentUserId;
  }

  String _buildReportFetchKey(String groupId) {
    return [
      groupId,
      _selectedSpeciesQuery ?? '',
      _selectedTimeQuery ?? '',
      _selectedMethodQuery ?? '',
      _selectedDepthRange?.join('-') ?? '',
    ].join('|');
  }

  String? get _selectedSpeciesQuery {
    final value = selectedReportSpecies.value;
    if (value == null || value == 'All Species') return null;
    return value;
  }

  String? get _selectedTimeQuery {
    final value = selectedReportTime.value;
    if (value == null || value == 'All Time') return null;
    return value;
  }

  String? get _selectedMethodQuery {
    final value = selectedReportMethod.value;
    if (value == null || value == 'All Methods') return null;
    return value.trim().toUpperCase().replaceAll(' ', '_');
  }

  List<int?>? get _selectedDepthRange {
    final value = selectedReportDepth.value;
    if (value == null || value == 'All Depths') return null;
    final match = RegExp(r'^(\d+)-(\d+)\+?ft$').firstMatch(value);
    if (match == null) return null;
    final min = int.parse(match.group(1)!);
    final maxStr = match.group(2)!;
    final isPlus = value.contains('+');
    return [min, isPlus ? null : int.parse(maxStr)];
  }

  void selectReportSpecies(String species) {
    selectedReportSpecies.value = species == 'All Species' ? null : species;
    _refetchReportsForCurrentGroup();
  }

  void selectReportDepth(String depth) {
    selectedReportDepth.value = depth == 'All Depths' ? null : depth;
    _refetchReportsForCurrentGroup();
  }

  void selectReportMethod(String method) {
    selectedReportMethod.value = method == 'All Methods' ? null : method;
    _refetchReportsForCurrentGroup();
  }

  void selectReportTime(String time) {
    selectedReportTime.value = time == 'All Time' ? null : time;
    _refetchReportsForCurrentGroup();
  }

  void _refetchReportsForCurrentGroup() {
    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) return;
    fetchReportForGroup(groupId: id);
  }

  void resetReportFilters() {
    selectedReportSpecies.value = null;
    selectedReportDepth.value = null;
    selectedReportMethod.value = null;
    selectedReportTime.value = null;
    _lastReportFetchKey = null;
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

  Future<void> inviteSelectedFriends() async {
    if (selectedFriendIds.isEmpty) return;

    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] inviteSelectedFriends failed: Group ID is missing',
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Group ID is missing. Please reload the group.',
      );
      return;
    }

    await EasyLoading.show(status: 'Sending invitations...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.postRequest(
        ApiConstants.generateGroupInvitationCodeApi(id),
        body: {'type': 'USER', 'inviteeUserIds': selectedFriendIds.toList()},
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] inviteSelectedFriends success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final int invitedCount = selectedFriendIds.length;
        closeInviteMembersSheet();
        _showInviteFeedback(
          invitedCount == 1
              ? '1 friend invited'
              : '$invitedCount friends invited',
        );

        if (_isCurrentUserGroupOwner()) {
          fetchPendingGroupInvites(showHUD: false);
        }
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] inviteSelectedFriends failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error(
        '[GroupDetails] inviteSelectedFriends exception',
        e,
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  Future<void> copyInviteCode() async {
    if (inviteCode.value.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: inviteCode.value));
      _showInviteFeedback('Invite code copied');
    }
  }

  Future<void> inviteWithCode() async {
    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] inviteWithCode failed: Group ID is missing',
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Group ID is missing. Please reload the group.',
      );
      return;
    }

    await EasyLoading.show(status: 'Generating invite code...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.postRequest(
        ApiConstants.generateGroupInvitationCodeApi(id),
        body: {'type': 'CODE'},
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] inviteWithCode success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawData = body is Map ? body['data'] : null;
        if (rawData is Map) {
          final code = rawData['inviteCode'] as String?;
          if (code != null && code.isNotEmpty) {
            inviteCode.value = code;
          } else {
            AppLoggerHelper.error(
              '[GroupDetails] inviteCode not found in response data',
            );
          }
        }
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] inviteWithCode failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] inviteWithCode exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  Future<void> sendEmailInvites() async {
    final emails = parsedInviteEmails;
    if (emails.isEmpty) return;

    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] sendEmailInvites failed: Group ID is missing',
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Group ID is missing. Please reload the group.',
      );
      return;
    }

    await EasyLoading.show(status: 'Sending invitations...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      for (final email in emails) {
        final response = await _networkCaller.postRequest(
          ApiConstants.generateGroupInvitationCodeApi(id),
          body: {'type': 'EMAIL', 'inviteeEmail': email},
          token: token,
        );

        if (!response.isSuccess) {
          AppLoggerHelper.error(
            '[GroupDetails] sendEmailInvites failed | '
            'email: $email | '
            'statusCode: ${response.statusCode} | '
            'error: ${response.errorMessage}',
          );
          CommonMessage.showMessage(
            title: 'Failed',
            message: response.errorMessage,
          );
          return;
        }

        AppLoggerHelper.info(
          '[GroupDetails] sendEmailInvites success | '
          'email: $email | '
          'statusCode: ${response.statusCode} | '
          'body: ${response.responseData}',
        );
      }

      closeInviteMembersSheet();
      _showInviteFeedback(
        emails.length == 1
            ? 'Invite sent to 1 email'
            : 'Invites sent to ${emails.length} emails',
      );

      if (_isCurrentUserGroupOwner()) {
        fetchPendingGroupInvites(showHUD: false);
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] sendEmailInvites exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
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
    inviteCode.value = '';

    _currentPage = 1;
    _hasMore = true;
    _isPaginationLoading = false;
    _lastSearchQuery = '';
    searchUserTEController.clear();
    searchQuery.value = '';
    invitableFriends.clear();
    fetchUserForInvitation(isRefresh: true);
  }

  // ── Fetch all pending invitations for the current group ──────────
  Future<void> fetchPendingGroupInvites({bool showHUD = true}) async {
    final id = _groupId ?? groupDetail.value?.groupId;
    if (id == null || id.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] fetchPendingGroupInvites failed: Group ID is missing',
      );
      return;
    }

    if (showHUD) {
      await EasyLoading.show(status: 'Loading pending invites...');
    }

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.getRequest(
        ApiConstants.showAllPendingInvitationOfAGroupApi(id),
        token: token,
      );

      if (response.isSuccess) {
        final body = response.responseData;
        AppLoggerHelper.info(
          '[GroupDetails] fetchPendingGroupInvites success | '
          'statusCode: ${response.statusCode} | '
          'body: $body',
        );

        final rawData = body is Map ? body['data'] : null;
        if (rawData is List) {
          final all = rawData
              .map(
                (e) => PendingGroupInviteItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
          // Keep only PENDING status items
          pendingGroupInvites.assignAll(
            all.where((item) => item.status == 'PENDING').toList(),
          );
        } else {
          pendingGroupInvites.clear();
        }
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] fetchPendingGroupInvites failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
      }
    } catch (e) {
      AppLoggerHelper.error(
        '[GroupDetails] fetchPendingGroupInvites exception',
        e,
      );
    } finally {
      if (showHUD) {
        await EasyLoading.dismiss();
      }
    }
  }

  // ── Revoke (cancel) a pending group invite ────────────────────────
  Future<void> revokeGroupInvite(PendingGroupInviteItem invite) async {
    await EasyLoading.show(status: 'Revoking invite...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.deleteRequest(
        ApiConstants.revokeInvitationUserApi(invite.id),
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          '[GroupDetails] revokeGroupInvite success | '
          'inviteId: ${invite.id} | '
          'statusCode: ${response.statusCode}',
        );
        // Remove from local list immediately for instant UI feedback
        pendingGroupInvites.removeWhere((item) => item.id == invite.id);
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] revokeGroupInvite failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] revokeGroupInvite exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
  }

  // ── Remove a member from the group (owner only) ────────────────────
  Future<void> removeMember(GroupDetailMember member) async {
    final groupId = _groupId ?? groupDetail.value?.groupId;
    if (groupId == null || groupId.isEmpty) {
      AppLoggerHelper.error(
        '[GroupDetails] removeMember failed: Group ID is missing',
      );
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Group ID is missing. Please reload the group.',
      );
      return;
    }

    await EasyLoading.show(status: 'Removing member...');

    try {
      final accessToken = StorageService.token;
      final token = (accessToken != null && accessToken.isNotEmpty)
          ? 'Bearer $accessToken'
          : null;

      final response = await _networkCaller.deleteRequest(
        ApiConstants.removeMemberFromGroupByOwnerApi(groupId, member.userId),
        token: token,
      );

      if (response.isSuccess) {
        AppLoggerHelper.info(
          '[GroupDetails] removeMember success | '
          'groupId: $groupId | '
          'userId: ${member.userId} | '
          'statusCode: ${response.statusCode}',
        );

        // Remove from local members list for instant UI feedback
        final current = groupDetail.value;
        if (current != null) {
          final updatedMembers = current.members
              .where((m) => m.userId != member.userId)
              .toList();
          groupDetail.value = GroupDetailModel(
            groupId: current.groupId,
            name: current.name,
            description: current.description,
            photoUrl: current.photoUrl,
            isPrivate: current.isPrivate,
            isActive: current.isActive,
            createdBy: current.createdBy,
            inviteCode: current.inviteCode,
            createdAt: current.createdAt,
            updatedAt: current.updatedAt,
            members: updatedMembers,
          );
        }

        CommonMessage.showMessage(
          title: 'Success',
          message: 'Member removed successfully.',
        );
      } else {
        AppLoggerHelper.error(
          '[GroupDetails] removeMember failed | '
          'statusCode: ${response.statusCode} | '
          'error: ${response.errorMessage}',
        );
        CommonMessage.showMessage(
          title: 'Failed',
          message: response.errorMessage,
        );
      }
    } catch (e) {
      AppLoggerHelper.error('[GroupDetails] removeMember exception', e);
      CommonMessage.showMessage(
        title: 'Error',
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      await EasyLoading.dismiss();
    }
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
    searchUserTEController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    inviteFriendsScrollController
      ..removeListener(_scrollListener)
      ..dispose();
    messageController.dispose();
    groupNameTEController.dispose();
    groupDescriptionTEController.dispose();
    super.onClose();
  }
}

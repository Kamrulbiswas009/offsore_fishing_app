import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/services/network_caller.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class NotificationScreenController extends GetxController {
  static const int _pageSize = 20;

  final Rx<NotificationTab> selectedTab = NotificationTab.all.obs;
  final RxList<NotificationItemModel> notifications =
      <NotificationItemModel>[].obs;
  final RxInt unreadNotificationCount = 0.obs;
  final RxMap<String, int> unreadMessageCounts = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final ScrollController scrollController = ScrollController();

  final NetworkCaller _networkCaller = NetworkCaller();
  io.Socket? _socket;
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  String get _notificationsUrl => '${ApiConstants.baseUrl}/notifications';
  String? get _token {
    final token = StorageService.token;
    return token == null || token.isEmpty ? null : 'Bearer $token';
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    fetchNotifications(refresh: true);
    fetchUnreadCount();
    _connectSocket();
  }

  void changeTab(NotificationTab tab) {
    selectedTab.value = tab;
  }

  List<NotificationItemModel> get filteredNotifications {
    if (selectedTab.value == NotificationTab.unread) {
      return notifications.where((item) => item.isUnread).toList();
    }
    return notifications;
  }

  int get unreadCount => unreadNotificationCount.value;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoadingMore || (!refresh && !_hasMore)) return;
    if (_token == null) return;

    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    _isLoadingMore = true;
    if (refresh) isLoading.value = true;

    try {
      final uri = Uri.parse(_notificationsUrl).replace(
        queryParameters: <String, String>{
          'page': _page.toString(),
          'limit': _pageSize.toString(),
          'unreadOnly': 'false',
        },
      );
      final response = await _networkCaller.getRequest(
        uri.toString(),
        token: _token,
      );

      if (!response.isSuccess) {
        AppLoggerHelper.error(
          '[Notifications] fetch failed',
          response.errorMessage,
        );
        return;
      }

      final body = _asMap(response.responseData);
      final data = body['data'];
      final dataMap = _asMap(data);
      final rawItems = data is List
          ? data
          : (dataMap['notifications'] ?? dataMap['items']) as List<dynamic>? ??
                const <dynamic>[];
      final loaded = rawItems
          .whereType<Map>()
          .map(
            (item) =>
                NotificationItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      if (refresh) {
        notifications.assignAll(loaded);
      } else {
        final knownIds = notifications.map((item) => item.id).toSet();
        notifications.addAll(
          loaded.where(
            (item) => item.id.isEmpty || !knownIds.contains(item.id),
          ),
        );
      }

      final meta = _asMap(body['meta']).isNotEmpty
          ? _asMap(body['meta'])
          : _asMap(dataMap['meta']);
      final totalPages = _toInt(meta['totalPages']);
      _hasMore = totalPages == null
          ? loaded.length >= _pageSize
          : _page < totalPages;
      if (_hasMore) _page++;
    } catch (error) {
      AppLoggerHelper.error('[Notifications] fetch exception', error);
    } finally {
      _isLoadingMore = false;
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    if (_token == null) return;
    try {
      final response = await _networkCaller.getRequest(
        '$_notificationsUrl/unread-count',
        token: _token,
      );
      if (!response.isSuccess) return;
      final body = _asMap(response.responseData);
      final data = body['data'];
      final count = data is Map ? _toInt(data['count']) : _toInt(data);
      if (count != null) unreadNotificationCount.value = count;
    } catch (error) {
      AppLoggerHelper.error('[Notifications] unread count exception', error);
    }
  }

  Future<void> markAsRead(NotificationItemModel item) async {
    if (!item.isUnread || item.id.isEmpty || _token == null) return;
    try {
      final response = await _networkCaller.patchRequest(
        '$_notificationsUrl/${item.id}/read',
        body: const <String, dynamic>{},
        token: _token,
      );
      if (!response.isSuccess) return;

      final index = notifications.indexWhere((entry) => entry.id == item.id);
      if (index != -1) notifications[index] = notifications[index].copyAsRead();
      if (unreadNotificationCount.value > 0) unreadNotificationCount.value--;
    } catch (error) {
      AppLoggerHelper.error('[Notifications] mark read exception', error);
    }
  }

  Future<void> markAllAsRead() async {
    if (_token == null || unreadNotificationCount.value == 0) return;
    try {
      final response = await _networkCaller.patchRequest(
        '$_notificationsUrl/read-all',
        body: const <String, dynamic>{},
        token: _token,
      );
      if (!response.isSuccess) return;
      notifications.assignAll(notifications.map((item) => item.copyAsRead()));
      unreadNotificationCount.value = 0;
    } catch (error) {
      AppLoggerHelper.error('[Notifications] mark all read exception', error);
    }
  }

  void _connectSocket() {
    final token = StorageService.token;
    if (token == null || token.isEmpty) return;

    _socket?.dispose();
    _socket = io.io(
      ApiConstants.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .setAuth(<String, dynamic>{
            'token': token,
            'authorization': 'Bearer $token',
          })
          .setExtraHeaders(<String, dynamic>{'Authorization': 'Bearer $token'})
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        _requestLiveCounts();
        fetchNotifications(refresh: true);
      })
      ..on('notificationCount', _handleNotificationCount)
      ..on('unreadMessageCounts', _handleUnreadMessageCounts)
      ..connect();
  }

  void _requestLiveCounts() {
    _socket?.emitWithAck(
      'getNotificationCount',
      null,
      ack: (response) {
        final data = _asMap(_asMap(response)['data']);
        final count = _toInt(data['count']);
        if (count != null) unreadNotificationCount.value = count;
      },
    );
    _socket?.emitWithAck(
      'getUnreadMessageCounts',
      null,
      ack: (response) {
        final responseMap = _asMap(response);
        _handleUnreadMessageCounts(responseMap['data']);
      },
    );
  }

  void _handleNotificationCount(dynamic payload) {
    final count = _toInt(_asMap(payload)['count']);
    if (count == null) return;
    final increased = count > unreadNotificationCount.value;
    unreadNotificationCount.value = count;
    if (increased) fetchNotifications(refresh: true);
  }

  void _handleUnreadMessageCounts(dynamic payload) {
    final map = _asMap(payload);
    final groups = payload is List ? payload : map['groups'];
    if (groups is! List) return;
    unreadMessageCounts.assignAll(<String, int>{
      for (final group in groups.whereType<Map>())
        if ((group['groupId'] ?? '').toString().isNotEmpty)
          (group['groupId']).toString(): _toInt(group['unreadCount']) ?? 0,
    });
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.extentAfter < 200) fetchNotifications();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  int? _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  @override
  void onClose() {
    scrollController.dispose();
    _socket?.dispose();
    super.onClose();
  }
}

enum NotificationTab { all, unread }

class NotificationItemModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isUnread;
  final String type;
  final String groupId;
  final String groupName;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isUnread,
    this.type = '',
    this.groupId = '',
    this.groupName = '',
  });

  bool get isGroupMessage {
    final messageKind = '$type $title'.toLowerCase();
    return groupId.isNotEmpty &&
        (messageKind.contains('message') || messageKind.contains('chat'));
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse((json['createdAt'] ?? '').toString());
    final explicitlyUnread = json['isUnread'];
    final isRead = json['isRead'] ?? json['read'];
    final data = _asMap(json['data']);
    final metadata = _asMap(json['metadata']);
    final payload = _asMap(json['payload']);
    final group = _asMap(
      json['group'] ?? data['group'] ?? metadata['group'] ?? payload['group'],
    );
    return NotificationItemModel(
      id: (json['notificationId'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['type'] ?? 'Notification').toString(),
      description:
          (json['description'] ?? json['message'] ?? json['body'] ?? '')
              .toString(),
      time: _formatTime(createdAt),
      isUnread: explicitlyUnread is bool
          ? explicitlyUnread
          : isRead is bool
          ? !isRead
          : json['readAt'] == null,
      type: _firstNonEmpty([
        json['type'],
        json['notificationType'],
        json['category'],
        data['type'],
        data['notificationType'],
        data['category'],
        metadata['type'],
        metadata['notificationType'],
        metadata['category'],
        payload['type'],
        payload['notificationType'],
        payload['category'],
      ]),
      groupId: _firstNonEmpty([
        json['groupId'],
        data['groupId'],
        metadata['groupId'],
        payload['groupId'],
        group['groupId'],
        group['id'],
      ]),
      groupName: _firstNonEmpty([
        json['groupName'],
        data['groupName'],
        metadata['groupName'],
        payload['groupName'],
        group['name'],
      ]),
    );
  }

  NotificationItemModel copyAsRead() => NotificationItemModel(
    id: id,
    title: title,
    description: description,
    time: time,
    isUnread: false,
    type: type,
    groupId: groupId,
    groupName: groupName,
  );

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _formatTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    final difference = DateTime.now().difference(local);
    if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat('MMM d, yyyy').format(local);
  }
}

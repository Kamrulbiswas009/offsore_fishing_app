import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paytonpieper/core/common/widgets/common_message.dart';
import 'package:paytonpieper/core/services/storage_service.dart';
import 'package:paytonpieper/core/utils/constants/api_constants.dart';
import 'package:paytonpieper/core/utils/constants/image_path.dart';
import 'package:paytonpieper/core/utils/logging/logger.dart';
import 'package:paytonpieper/features/groups/model/group_details_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class MessageServiceController extends GetxController {
  static const int _pageSize = 50;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxList<GroupChatMessage> messages = <GroupChatMessage>[].obs;
  final RxMap<String, String> typingUsers = <String, String>{}.obs;
  final RxList<String> onlineUserIds = <String>[].obs;
  final RxBool isConnected = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  final Rxn<GroupChatMessage> replyingTo = Rxn<GroupChatMessage>();

  io.Socket? _socket;
  String? _activeGroupId;
  String? _nextCursor;
  bool _isLoadingMore = false;
  Timer? _typingStopTimer;
  bool _hasSentTypingStart = false;

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_handleMessageTextChanged);
    scrollController.addListener(_handleScroll);
  }

  Future<void> openGroup(String? groupId) async {
    if (groupId == null || groupId.isEmpty) return;
    if (_activeGroupId == groupId && _socket != null) return;

    _activeGroupId = groupId;
    _nextCursor = null;
    hasMoreMessages.value = true;
    typingUsers.clear();
    onlineUserIds.clear();
    messages.clear();
    replyingTo.value = null;

    _connectSocket();
  }

  Future<void> loadOlderMessages() async {
    final groupId = _activeGroupId;
    final socket = _socket;
    if (groupId == null ||
        socket == null ||
        _isLoadingMore ||
        !hasMoreMessages.value) {
      return;
    }

    _isLoadingMore = true;
    isLoadingMessages.value = true;

    socket.emitWithAck(
      'getMessages',
      {'groupId': groupId, 'cursor': _nextCursor, 'take': _pageSize},
      ack: (response) {
        try {
          final ackData = _asMap(response);
          if (ackData['success'] == true) {
            final data = _asMap(ackData['data']);
            final rawMessages = data['messages'] as List<dynamic>? ?? [];
            final loadedMessages = rawMessages
                .whereType<Map>()
                .map(
                  (item) => _withReplyFallback(
                    _messageFromJson(Map<String, dynamic>.from(item)),
                  ),
                )
                .toList();

            _nextCursor = data['nextCursor'] as String?;
            hasMoreMessages.value = data['hasMore'] == true;
            _prependMessages(loadedMessages);
          } else {
            AppLoggerHelper.error(
              '[MessageService] getMessages failed',
              ackData['error'],
            );
          }
        } catch (error) {
          AppLoggerHelper.error(
            '[MessageService] getMessages exception',
            error,
          );
        } finally {
          _isLoadingMore = false;
          isLoadingMessages.value = false;
        }
      },
    );
  }

  Future<void> sendMessage({String type = 'TEXT', String? replyToId}) async {
    final groupId = _activeGroupId;
    final text = messageController.text.trim();
    final selectedReplyToId = replyToId ?? replyingTo.value?.messageId;

    if (text.isEmpty) return;

    if (groupId == null || groupId.isEmpty) {
      CommonMessage.showMessage(
        title: 'Message',
        message: 'Group is still loading. Please try again.',
      );
      return;
    }

    isSending.value = true;
    final selectedReply = replyingTo.value;

    final connected = await _ensureSocketConnected();
    final socket = _socket;
    if (!connected || socket == null) {
      isSending.value = false;
      CommonMessage.showMessage(
        title: 'Message',
        message: 'Chat is not connected. Please try again.',
      );
      return;
    }

    _emitTyping(false);

    socket.emitWithAck(
      'sendMessage',
      {
        'groupId': groupId,
        'content': text,
        'type': type,
        'replyToId': selectedReplyToId,
      },
      ack: (response) {
        try {
          final ackData = _asMap(response);
          if (ackData['success'] == true) {
            messageController.clear();
            replyingTo.value = null;
            final data = ackData['data'];
            if (data is Map) {
              final sentMessage = _withReplyFallback(
                _messageFromJson(Map<String, dynamic>.from(data)),
                selectedReply,
              );
              _upsertMessage(sentMessage);
              _scrollToBottom();
            }
          } else {
            CommonMessage.showMessage(
              title: 'Message',
              message: (ackData['error'] ?? 'Unable to send message.')
                  .toString(),
            );
          }
        } catch (error) {
          AppLoggerHelper.error(
            '[MessageService] sendMessage exception',
            error,
          );
        } finally {
          isSending.value = false;
        }
      },
    );
  }

  void startReply(GroupChatMessage message) {
    if (message.messageId.isEmpty || message.isDeleted) return;
    replyingTo.value = message;
  }

  void cancelReply() {
    replyingTo.value = null;
  }

  Future<void> deleteMessage(String messageId) async {
    final groupId = _activeGroupId;
    final socket = _socket;
    if (messageId.isEmpty || groupId == null || socket == null) return;

    socket.emitWithAck(
      'deleteMessage',
      {'messageId': messageId, 'groupId': groupId},
      ack: (response) {
        try {
          final ackData = _asMap(response);
          if (ackData['success'] != true) {
            CommonMessage.showMessage(
              title: 'Message',
              message: (ackData['error'] ?? 'Unable to delete message.')
                  .toString(),
            );
          }
        } catch (error) {
          AppLoggerHelper.error(
            '[MessageService] deleteMessage exception',
            error,
          );
        }
      },
    );
  }

  Future<void> getOnlineUsers() async {
    final groupId = _activeGroupId;
    final socket = _socket;
    if (groupId == null || socket == null) return;

    socket.emitWithAck(
      'getOnlineUsers',
      {'groupId': groupId},
      ack: (response) {
        try {
          final ackData = _asMap(response);
          if (ackData['success'] == true && ackData['data'] is List) {
            onlineUserIds.assignAll(List<String>.from(ackData['data'] as List));
          }
        } catch (error) {
          AppLoggerHelper.error(
            '[MessageService] getOnlineUsers exception',
            error,
          );
        }
      },
    );
  }

  void _connectSocket() {
    final token = StorageService.token;
    if (token == null || token.isEmpty) {
      connectionStatus.value = 'Token missing';
      AppLoggerHelper.error('[MessageService] socket skipped: token missing');
      return;
    }

    connectionStatus.value = 'Connecting...';
    _socket?.dispose();
    final socketUrl = ApiConstants.socketBaseUrl;
    AppLoggerHelper.info('[MessageService] connecting socket: $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer $token'})
          .setExtraHeaders({'authorization': 'Bearer $token'})
          .setQuery({'token': 'Bearer $token'})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .enableForceNew()
          .disableAutoConnect()
          .build(),
    );

    _registerSocketListeners(_socket!);
    _socket!.connect();
  }

  void _registerSocketListeners(io.Socket socket) {
    socket.onConnect((_) {
      isConnected.value = true;
      connectionStatus.value = 'Connected';
      loadOlderMessages();
      getOnlineUsers();
      AppLoggerHelper.info('[MessageService] socket connected');
    });

    socket.onDisconnect((data) {
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      typingUsers.clear();
      AppLoggerHelper.info('[MessageService] socket disconnected: $data');
    });

    socket.onConnectError((error) {
      isConnected.value = false;
      connectionStatus.value = 'Connection error';
      AppLoggerHelper.error('[MessageService] socket connect error', error);
    });

    socket.onError((error) {
      isConnected.value = false;
      connectionStatus.value = 'Connection error';
      AppLoggerHelper.error('[MessageService] socket error', error);
    });

    socket.on('newMessage', (data) {
      try {
        final message = _withReplyFallback(_messageFromJson(_asMap(data)));
        if (message.groupId != _activeGroupId) return;
        _upsertMessage(message);
        _scrollToBottom();
      } catch (error) {
        AppLoggerHelper.error('[MessageService] newMessage exception', error);
      }
    });

    socket.on('userTyping', (data) {
      try {
        final status = _asMap(data);
        if (status['groupId'] != _activeGroupId) return;

        final userId = (status['userId'] ?? '').toString();
        final isTyping = status['isTyping'] == true;
        if (userId.isEmpty || userId == StorageService.userId) return;

        if (isTyping) {
          typingUsers[userId] = (status['name'] ?? 'Someone').toString();
        } else {
          typingUsers.remove(userId);
        }
      } catch (error) {
        AppLoggerHelper.error('[MessageService] userTyping exception', error);
      }
    });

    socket.on('messageDeleted', (data) {
      try {
        final deleted = _asMap(data);
        if (deleted['groupId'] != _activeGroupId) return;
        _markMessageDeleted((deleted['messageId'] ?? '').toString());
      } catch (error) {
        AppLoggerHelper.error(
          '[MessageService] messageDeleted exception',
          error,
        );
      }
    });
  }

  void _handleMessageTextChanged() {
    if (messageController.text.trim().isEmpty) {
      _emitTyping(false);
      return;
    }

    if (!_hasSentTypingStart) {
      _emitTyping(true);
    }

    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 2), () {
      _emitTyping(false);
    });
  }

  Future<bool> _ensureSocketConnected() async {
    if (_socket?.connected == true) return true;

    if (_socket == null) {
      _connectSocket();
    } else {
      connectionStatus.value = 'Connecting...';
      _socket!.connect();
    }

    for (var attempt = 0; attempt < 24; attempt++) {
      if (_socket?.connected == true) return true;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    connectionStatus.value = 'Disconnected';
    AppLoggerHelper.error(
      '[MessageService] socket connect timeout',
      'url: ${ApiConstants.socketBaseUrl}, groupId: $_activeGroupId',
    );
    return false;
  }

  void _emitTyping(bool isTyping) {
    final groupId = _activeGroupId;
    final socket = _socket;
    if (groupId == null || socket == null) return;

    if (_hasSentTypingStart == isTyping && isTyping) return;
    _hasSentTypingStart = isTyping;

    socket.emit('typing', {'groupId': groupId, 'isTyping': isTyping});
  }

  void _handleScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels <= 120) {
      loadOlderMessages();
    }
  }

  void _prependMessages(List<GroupChatMessage> loadedMessages) {
    if (loadedMessages.isEmpty) return;

    final existingIds = messages.map((message) => message.messageId).toSet();
    final uniqueMessages = loadedMessages
        .where(
          (message) =>
              message.messageId.isEmpty ||
              !existingIds.contains(message.messageId),
        )
        .toList();

    uniqueMessages.sort(_sortByCreatedAt);
    messages.insertAll(0, uniqueMessages);
  }

  void _upsertMessage(GroupChatMessage message) {
    final index = messages.indexWhere(
      (item) =>
          item.messageId.isNotEmpty && item.messageId == message.messageId,
    );

    if (index == -1) {
      messages.add(message);
      messages.sort(_sortByCreatedAt);
      return;
    }

    messages[index] = message;
  }

  void _markMessageDeleted(String messageId) {
    final index = messages.indexWhere(
      (message) => message.messageId == messageId,
    );
    if (index == -1) return;

    final old = messages[index];
    messages[index] = GroupChatMessage(
      messageId: old.messageId,
      groupId: old.groupId,
      senderId: old.senderId,
      sender: old.sender,
      text: 'Message deleted',
      time: old.time,
      isMine: old.isMine,
      avatarPath: old.avatarPath,
      type: old.type,
      isEdited: old.isEdited,
      isDeleted: true,
      replyToId: old.replyToId,
      replySender: old.replySender,
      replyText: old.replyText,
      createdAt: old.createdAt,
    );
  }

  GroupChatMessage _messageFromJson(Map<String, dynamic> json) {
    final sender = _asNullableMap(json['sender']);
    final senderId = (json['senderId'] ?? sender?['userId'] ?? '').toString();
    final createdAt = DateTime.tryParse((json['createdAt'] ?? '').toString());
    final isDeleted = json['isDeleted'] == true;
    final replyTo = _asNullableMap(json['replyTo']);
    final replyToSender = _asNullableMap(replyTo?['sender']);
    final replyToId =
        (json['replyToId'] as String?) ??
        (replyTo?['messageId'] as String?) ??
        (replyTo?['id'] as String?);

    return GroupChatMessage(
      messageId: (json['messageId'] ?? '').toString(),
      groupId: (json['groupId'] ?? '').toString(),
      senderId: senderId,
      sender:
          (sender?['name'] ?? (senderId == StorageService.userId ? 'You' : ''))
              .toString(),
      text: isDeleted ? 'Message deleted' : (json['content'] ?? '').toString(),
      time: _formatMessageTime(createdAt),
      isMine: senderId.isNotEmpty && senderId == StorageService.userId,
      avatarPath:
          (sender?['profileImage'] as String?) ?? ImagePath.messageProfileImage,
      type: (json['type'] ?? 'TEXT').toString(),
      isEdited: json['isEdited'] == true,
      isDeleted: isDeleted,
      replyToId: replyToId,
      replySender: replyTo == null
          ? null
          : (replyToSender?['name'] ?? 'Replied message').toString(),
      replyText: replyTo == null
          ? null
          : (replyTo['isDeleted'] == true
                ? 'Message deleted'
                : (replyTo['content'] ?? '').toString()),
      createdAt: createdAt,
    );
  }

  GroupChatMessage _withReplyFallback(
    GroupChatMessage message, [
    GroupChatMessage? selectedReply,
  ]) {
    if (message.replyToId == null ||
        message.replyToId!.isEmpty ||
        (message.replyText?.isNotEmpty ?? false)) {
      return message;
    }

    GroupChatMessage? reply = selectedReply;
    if (reply == null || reply.messageId != message.replyToId) {
      for (final item in messages) {
        if (item.messageId == message.replyToId) {
          reply = item;
          break;
        }
      }
    }

    if (reply == null) return message;

    return GroupChatMessage(
      messageId: message.messageId,
      groupId: message.groupId,
      senderId: message.senderId,
      sender: message.sender,
      text: message.text,
      time: message.time,
      isMine: message.isMine,
      avatarPath: message.avatarPath,
      type: message.type,
      isEdited: message.isEdited,
      isDeleted: message.isDeleted,
      replyToId: message.replyToId,
      replySender: reply.isMine ? 'You' : reply.sender,
      replyText: reply.text,
      createdAt: message.createdAt,
    );
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return 'Now';
    return DateFormat('h:mma').format(dateTime.toLocal()).toLowerCase();
  }

  int _sortByCreatedAt(GroupChatMessage a, GroupChatMessage b) {
    final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aTime.compareTo(bTime);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Map<String, dynamic>? _asNullableMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void onClose() {
    _typingStopTimer?.cancel();
    _emitTyping(false);
    _socket?.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

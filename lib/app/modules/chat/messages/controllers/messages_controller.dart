import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../services/messages_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/message_model.dart';
import '../../../../services/follow_service.dart';

class MessagesController extends GetxController {
  late final MessagesService api;
  final messages = <Map<String, dynamic>>[].obs;
  final textController = ''.obs;
  final textEditingController = TextEditingController();
  final isLoading = false.obs;
  final isFollowing = false.obs;

  int? _currentUserId() {
    try {
      final auth = Get.find<AuthService>();
      return auth.user.value?['id'] as int?;
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure singleton MessagesService and subscribe to updates
    if (!Get.isRegistered<MessagesService>()) {
      Get.put(MessagesService(), permanent: true);
    }
    api = Get.find<MessagesService>();
    ever(api.messages, (_) => _syncFromModels());
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await api.init();
    final args = Get.arguments is Map<String, dynamic>
        ? (Get.arguments as Map<String, dynamic>)
        : <String, dynamic>{};

    // Prefer explicit conversation/room id; otherwise, ensure DM with userId
    final int? roomId = _toInt(args['roomId'] ?? args['conversationId']);
    int? userId = _toInt(args['userId']);
    userId ??= _inferPeerUserId(args);

    // Initialize following status if provided by rooms payload
    final room = args['room'];
    if (args['is_following'] is bool) {
      isFollowing.value = args['is_following'] as bool;
    } else if (room is Map<String, dynamic> && room['is_following'] is bool) {
      isFollowing.value = room['is_following'] as bool;
    }

    int? useRoomId = roomId ?? api.currentRoomId.value;
    if (useRoomId == null && userId != null) {
      useRoomId = await api.ensureDmRoomWithUser(userId);
    }
    if (useRoomId != null) {
      // Set current room id early so subsequent actions use correct conversation
      api.currentRoomId.value = useRoomId;
      bool loaded = false;
      try {
        isLoading.value = true;
        debugPrint('[MessagesController] loadMessages useRoomId=$useRoomId');
        await api.loadMessages(useRoomId);
        loaded = true;
      } catch (_) {}
      // If no messages loaded or load failed, ensure DM and reload
      if (!loaded || api.messages.isEmpty) {
        int? candidateUserId = userId;
        if (candidateUserId == null) {
          final room = args['room'];
          if (room is Map<String, dynamic>) {
            candidateUserId = _toInt(room['id']) ?? _inferPeerUserId(args);
          }
        }
        if (candidateUserId != null) {
          debugPrint(
            '[MessagesController] ensureDmRoomWithUser userId=$candidateUserId',
          );
          final rid = await api.ensureDmRoomWithUser(candidateUserId);
          if (rid != null) {
            debugPrint('[MessagesController] retry loadMessages rid=$rid');
            await api.loadMessages(rid);
          }
        }
      }
      isLoading.value = false;
      debugPrint(
        '[MessagesController] messages loaded count=${api.messages.length}',
      );
      _syncFromModels();
    }
  }

  void _syncFromModels() {
    final meId = _currentUserId();
    final list = api.messages.map((MessageModel m) {
      final fromMe = m.fromMe ?? (meId != null && m.senderId == meId);
      return {
        'fromMe': fromMe,
        'text': m.text,
        'time': m.createdAt?.toIso8601String(),
      };
    }).toList();
    messages.assignAll(list);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Ensure we have a valid room/conversation context
    final args = Get.arguments is Map<String, dynamic>
        ? (Get.arguments as Map<String, dynamic>)
        : <String, dynamic>{};
    final int? argId = _toInt(
      args['roomId'] ??
          args['conversationId'] ??
          (args['room'] is Map<String, dynamic>
              ? (args['room'] as Map<String, dynamic>)['conversation_id']
              : null) ??
          (args['room'] is Map<String, dynamic>
              ? (args['room'] as Map<String, dynamic>)['id']
              : null),
    );
    if (api.currentRoomId.value == null ||
        (argId != null && api.currentRoomId.value != argId)) {
      final int? roomId = argId;
      final int? userId = _toInt(args['userId']);
      int? useRoomId = roomId;
      if (useRoomId == null && userId != null) {
        useRoomId = await api.ensureDmRoomWithUser(userId);
      }
      if (useRoomId != null) {
        // Set and load to ensure sending uses the right conversation
        api.currentRoomId.value = useRoomId;
        isLoading.value = true;
        await api.loadMessages(useRoomId);
        isLoading.value = false;
      } else {
        // Without context, don't proceed
        return;
      }
    }

    // Optimistic UI: tampilkan bubble di kanan segera
    messages.add({
      'fromMe': true,
      'text': trimmed,
      'time': DateTime.now().toIso8601String(),
      'unsent': false,
    });
    textController.value = '';
    // Kosongkan field input secara langsung
    textEditingController.clear();

    try {
      // Kirim ke server; jika gagal, rollback bubble terakhir
      final sent = await api.sendMessage(trimmed);
      if (sent == null) {
        // Remove optimistic bubble if server didn't accept
        _removeLastIfMatches(trimmed);
        Get.snackbar('Message failed', 'Could not send message');
      }
    } catch (e) {
      // If follow is required, keep bubble as unsent and offer to follow
      final errText = e.toString();
      if (_isFollowRequiredError(errText)) {
        _markLastUnsent(trimmed);
        Get.snackbar(
          'Message failed',
          'Follow required to send this message',
          mainButton: TextButton(
            onPressed: () => _followAndResend(trimmed),
            child: const Text(
              'Follow & Send',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xFF4A1F7A),
          colorText: Colors.white,
        );
      } else {
        // General failure: attempt DM ensure once, then rollback
        try {
          final args = Get.arguments is Map<String, dynamic>
              ? (Get.arguments as Map<String, dynamic>)
              : <String, dynamic>{};
          final int? userId = _toInt(args['userId']);
          if (userId != null) {
            final roomId = await api.ensureDmRoomWithUser(userId);
            if (roomId != null) {
              await api.loadMessages(roomId);
              final retry = await api.sendMessage(trimmed);
              if (retry != null) {
                return;
              }
            }
          }
          _removeLastIfMatches(trimmed);
          Get.snackbar('Message failed', errText);
        } catch (e2) {
          _removeLastIfMatches(trimmed);
          Get.snackbar('Message failed', e2.toString());
        }
      }
    }
  }

  void _removeLastIfMatches(String text) {
    if (messages.isNotEmpty) {
      final last = messages.last;
      if (last['text'] == text && last['fromMe'] == true) {
        messages.removeLast();
      }
    }
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  int? _inferPeerUserId(Map<String, dynamic> args) {
    final room = args['room'];
    if (room is Map<String, dynamic>) {
      final meId = _currentUserId();
      final candidates = [
        room['other_user_id'],
        room['user_id'],
        room['peer_id'],
        room['friend_id'],
        room['id'], // fallback: some APIs use id as peer/user id
      ];
      for (final c in candidates) {
        final id = _toInt(c);
        if (id != null) return id;
      }
      // Try participants array: pick id != me
      final parts = room['participants'];
      if (parts is List) {
        for (final p in parts) {
          if (p is Map<String, dynamic>) {
            final id = _toInt(p['id']);
            if (id != null && id != meId) return id;
          }
        }
      }
    }
    return null;
  }

  bool _isFollowRequiredError(String text) {
    final t = text.toLowerCase();
    return t.contains('follow required');
  }

  void _markLastUnsent(String text) {
    if (messages.isNotEmpty) {
      final last = messages.last;
      if (last['text'] == text && last['fromMe'] == true) {
        last['unsent'] = true;
        messages[messages.length - 1] = last;
      }
    }
  }

  Future<void> _followAndResend(String text) async {
    final args = Get.arguments is Map<String, dynamic>
        ? (Get.arguments as Map<String, dynamic>)
        : <String, dynamic>{};
    final int? userId = _toInt(args['userId']);
    if (userId == null) {
      Get.snackbar('Follow failed', 'Missing user id');
      return;
    }
    // Ensure FollowService exists
    if (!Get.isRegistered<FollowService>()) {
      await Get.putAsync<FollowService>(() async => (FollowService()).init());
    }
    final follow = Get.find<FollowService>();
    final ok = await follow.follow(userId, createChatRoom: true);
    if (!ok) return;
    isFollowing.value = true;
    // After follow, reload messages context and resend
    final roomId =
        api.currentRoomId.value ?? await api.ensureDmRoomWithUser(userId);
    if (roomId != null) {
      await api.loadMessages(roomId);
    }
    // remove unsent bubble before resending to avoid duplicates
    _removeLastIfMatches(text);
    final sent = await api.sendMessage(text);
    if (sent == null) {
      Get.snackbar('Message failed', 'Could not send after follow');
      // optionally restore unsent bubble
      messages.add({
        'fromMe': true,
        'text': text,
        'time': DateTime.now().toIso8601String(),
        'unsent': true,
      });
    }
  }

  Future<void> followPeer() async {
    final args = Get.arguments is Map<String, dynamic>
        ? (Get.arguments as Map<String, dynamic>)
        : <String, dynamic>{};
    final int? userId = _toInt(args['userId'] ?? _inferPeerUserId(args));
    if (userId == null) {
      Get.snackbar('Follow failed', 'Missing user id');
      return;
    }
    // Ensure FollowService exists
    if (!Get.isRegistered<FollowService>()) {
      await Get.putAsync<FollowService>(() async => (FollowService()).init());
    }
    final follow = Get.find<FollowService>();
    final ok = await follow.follow(userId, createChatRoom: true);
    if (!ok) return;
    isFollowing.value = true;
    // After follow, ensure DM and reload messages
    final rid =
        api.currentRoomId.value ?? await api.ensureDmRoomWithUser(userId);
    if (rid != null) {
      await api.loadMessages(rid);
      _syncFromModels();
    }
  }
}

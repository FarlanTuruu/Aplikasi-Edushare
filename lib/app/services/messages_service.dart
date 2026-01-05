import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/chat_repository.dart';
import '../data/api_client.dart';
import '../services/auth_service.dart';
import '../models/message_model.dart';

class MessagesService extends GetxService {
  ChatRepository? _repo;
  ApiClient? _apiClient;
  final messages = <MessageModel>[].obs;
  final currentRoomId = RxnInt();
  bool _initialized = false;

  // Getters with lazy initialization
  ChatRepository get repo {
    if (_repo == null) {
      _apiClient ??= ApiClient();
      _repo = ChatRepository(_apiClient!);
    }
    return _repo!;
  }

  Future<MessagesService> init() async {
    if (_initialized) {
      debugPrint('[MessagesService] Already initialized, skipping');
      return this;
    }

    _apiClient = ApiClient();
    _repo = ChatRepository(_apiClient!);
    _initialized = true;
    debugPrint('[MessagesService] Initialized');
    return this;
  }

  int? get _currentUserId {
    try {
      final auth = Get.find<AuthService>();
      return auth.user.value?['id'] as int?;
    } catch (_) {
      return null;
    }
  }

  Future<int?> ensureDmRoomWithUser(int userId) async {
    try {
      debugPrint('[MessagesService] Ensuring DM room with user: $userId');
      final res = await repo.createOrGetDm(userId);

      // Extract room id from response
      final data = res['data'];
      int? roomId;

      if (data is Map<String, dynamic>) {
        roomId =
            _toInt(data['id']) ??
            _toInt(data['room_id']) ??
            _toInt(data['conversation_id']);
      }
      roomId ??=
          _toInt(res['id']) ??
          _toInt(res['room_id']) ??
          _toInt(res['conversation_id']);

      if (roomId != null) {
        currentRoomId.value = roomId;
        debugPrint('[MessagesService] DM room ensured: $roomId');
      } else {
        debugPrint(
          '[MessagesService] Failed to extract room ID from response: $res',
        );
      }

      return roomId;
    } catch (e) {
      debugPrint('[MessagesService] Error ensuring DM room: $e');
      rethrow;
    }
  }

  Future<void> loadMessages(int roomId) async {
    try {
      debugPrint('[MessagesService] Loading messages for room: $roomId');
      currentRoomId.value = roomId;

      final dynamic raw = await repo.getMessages(roomId);
      debugPrint('[MessagesService] Raw response type: ${raw.runtimeType}');

      Iterable items = const [];

      // Parse response with multiple possible structures
      if (raw is List) {
        items = raw;
        debugPrint(
          '[MessagesService] Response is List with ${items.length} items',
        );
      } else if (raw is Map<String, dynamic>) {
        debugPrint('[MessagesService] Response keys: ${raw.keys.join(", ")}');

        // Try multiple possible paths
        final d = raw['data'];
        if (d is List) {
          items = d;
          debugPrint('[MessagesService] Found data as List');
        } else if (d is Map<String, dynamic>) {
          debugPrint('[MessagesService] Data keys: ${d.keys.join(", ")}');

          // Laravel-style pagination: { data: { data: [...], meta: ... } }
          if (d['data'] is List) {
            items = d['data'] as List;
            debugPrint('[MessagesService] Found nested data.data as List');
          } else if (d['messages'] is List) {
            items = d['messages'] as List;
            debugPrint('[MessagesService] Found data.messages as List');
          } else if (d['items'] is List) {
            items = d['items'] as List;
            debugPrint('[MessagesService] Found data.items as List');
          }
        } else if (raw['messages'] is List) {
          items = raw['messages'] as List;
          debugPrint('[MessagesService] Found messages as List');
        } else if (raw['items'] is List) {
          items = raw['items'] as List;
          debugPrint('[MessagesService] Found items as List');
        }
      }

      // Parse items to MessageModel
      final parsed = items.map((e) {
        if (e is Map<String, dynamic>) {
          return MessageModel.fromJson(e);
        }
        return MessageModel(text: e.toString());
      }).toList();

      // Sort by created_at to ensure correct order (oldest first)
      parsed.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return -1;
        if (b.createdAt == null) return 1;
        return a.createdAt!.compareTo(b.createdAt!);
      });

      messages.assignAll(parsed);
      debugPrint('[MessagesService] ✅ Loaded ${parsed.length} messages');
    } catch (e, stackTrace) {
      debugPrint('[MessagesService] ❌ Error loading messages: $e');
      debugPrint('[MessagesService] Stack trace: $stackTrace');
      // Don't clear messages on error - keep existing messages
      rethrow;
    }
  }

  Future<MessageModel?> sendMessage(String text) async {
    final rid = currentRoomId.value;
    if (rid == null) {
      debugPrint('[MessagesService] Cannot send message: no current room');
      return null;
    }

    if (text.trim().isEmpty) {
      debugPrint('[MessagesService] Cannot send empty message');
      return null;
    }

    try {
      debugPrint('[MessagesService] Sending message to room $rid: $text');
      final res = await repo.sendMessage(rid, text);

      // Extract message from response
      Map<String, dynamic>? msgJson;
      if (res['data'] is Map<String, dynamic>) {
        msgJson = res['data'] as Map<String, dynamic>;
      } else if (res['message'] is Map<String, dynamic>) {
        msgJson = res['message'] as Map<String, dynamic>;
      } else if (res is Map<String, dynamic> && res['text'] != null) {
        msgJson = res;
      }

      final model = MessageModel.fromJson(
        msgJson ??
            {
              'text': text,
              'sender_id': _currentUserId,
              'created_at': DateTime.now().toIso8601String(),
            },
      );

      // Add to messages list to trigger UI update
      // Check if message already exists (by id or text+time)
      final alreadyExists = messages.any((m) {
        if (m.id != null && model.id != null) {
          return m.id == model.id;
        }
        // Fallback: check by text and approximate time
        return m.text == model.text &&
            m.senderId == model.senderId &&
            (m.createdAt == model.createdAt ||
                (m.createdAt != null &&
                    model.createdAt != null &&
                    m.createdAt!.difference(model.createdAt!).abs().inSeconds <
                        2));
      });

      if (!alreadyExists) {
        messages.add(model);
        debugPrint('[MessagesService] ✅ Message added to list');
      } else {
        debugPrint(
          '[MessagesService] Message already exists, skipping duplicate',
        );
      }

      return model;
    } catch (e, stackTrace) {
      debugPrint('[MessagesService] ❌ Error sending message: $e');
      debugPrint('[MessagesService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Refresh messages for current room
  Future<void> refreshMessages() async {
    final rid = currentRoomId.value;
    if (rid != null) {
      await loadMessages(rid);
    }
  }

  // Reset service state (useful for logout or switching accounts)
  void reset() {
    messages.clear();
    currentRoomId.value = null;
    debugPrint('[MessagesService] State reset');
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../services/messages_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/message_model.dart';

class MessagesController extends GetxController {
  late final MessagesService api;
  final messages = <Map<String, dynamic>>[].obs;
  final textController = ''.obs;
  final textEditingController = TextEditingController();

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

    // Prefer roomId if provided; otherwise, try ensure DM with userId
    final int? roomId = _toInt(args['roomId']);
    final int? userId = _toInt(args['userId']);

    int? useRoomId = roomId ?? api.currentRoomId.value;
    if (useRoomId == null && userId != null) {
      useRoomId = await api.ensureDmRoomWithUser(userId);
    }
    if (useRoomId != null) {
      await api.loadMessages(useRoomId);
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

    // Optimistic UI: tampilkan bubble di kanan segera
    messages.add({
      'fromMe': true,
      'text': trimmed,
      'time': DateTime.now().toIso8601String(),
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
      }
    } catch (_) {
      _removeLastIfMatches(trimmed);
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
}

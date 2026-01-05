import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import '../../../../services/messages_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/message_model.dart';
import '../../../../services/follow_service.dart';
import '../../../../data/config.dart';

class MessagesController extends GetxController {
  late final MessagesService api;
  final messages = <Map<String, dynamic>>[].obs;
  final textController = ''.obs;
  final textEditingController = TextEditingController();
  final isLoading = false.obs;
  final isFollowing = false.obs;
  final showEmojiPicker = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

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

    // Subscribe to messages updates
    ever(api.messages, (_) {
      debugPrint('[MessagesController] Messages updated, syncing to UI');
      _syncFromModels();
    });

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    isLoading.value = true;

    try {
      // Init service (safe to call multiple times)
      await api.init();
      final args = Get.arguments is Map<String, dynamic>
          ? (Get.arguments as Map<String, dynamic>)
          : <String, dynamic>{};

      // Extract all possible IDs
      final int? roomId = _toInt(args['roomId'] ?? args['conversationId']);
      int? userId = _toInt(args['userId']);
      userId ??= _inferPeerUserId(args);

      // Initialize following status if provided
      final room = args['room'];
      if (args['is_following'] is bool) {
        isFollowing.value = args['is_following'] as bool;
      } else if (room is Map<String, dynamic> && room['is_following'] is bool) {
        isFollowing.value = room['is_following'] as bool;
      }

      debugPrint(
        '[MessagesController] Bootstrap - roomId: $roomId, userId: $userId',
      );

      // Clear previous messages when entering new conversation
      messages.clear();

      // Priority 1: Use roomId if available
      if (roomId != null) {
        api.currentRoomId.value = roomId;
        await _loadMessagesForRoom(roomId);
      }
      // Priority 2: Use userId to ensure DM room exists
      else if (userId != null) {
        debugPrint(
          '[MessagesController] No roomId, ensuring DM with userId: $userId',
        );
        final ensuredRoomId = await api.ensureDmRoomWithUser(userId);
        if (ensuredRoomId != null) {
          api.currentRoomId.value = ensuredRoomId;
          await _loadMessagesForRoom(ensuredRoomId);
        }
      }
      // Priority 3: Check if api already has a current room
      else if (api.currentRoomId.value != null) {
        await _loadMessagesForRoom(api.currentRoomId.value!);
      }

      debugPrint(
        '[MessagesController] Bootstrap complete - messages count: ${api.messages.length}',
      );

      // Force sync after bootstrap
      _syncFromModels();
    } catch (e) {
      debugPrint('[MessagesController] Bootstrap error: $e');
      Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMessagesForRoom(int roomId) async {
    try {
      debugPrint('[MessagesController] Loading messages for room: $roomId');
      await api.loadMessages(roomId);

      // If messages loaded successfully, we're done
      if (api.messages.isNotEmpty) {
        debugPrint(
          '[MessagesController] Successfully loaded ${api.messages.length} messages',
        );
        return;
      }

      // If no messages but room exists, it might be a new conversation
      debugPrint(
        '[MessagesController] No messages found for room $roomId (might be new conversation)',
      );
    } catch (e) {
      debugPrint('[MessagesController] Error loading messages: $e');

      // If loading failed, try to recover by ensuring DM room exists
      final args = Get.arguments is Map<String, dynamic>
          ? (Get.arguments as Map<String, dynamic>)
          : <String, dynamic>{};
      int? userId = _toInt(args['userId']);
      userId ??= _inferPeerUserId(args);

      if (userId != null) {
        debugPrint(
          '[MessagesController] Attempting recovery with userId: $userId',
        );
        final recoveredRoomId = await api.ensureDmRoomWithUser(userId);
        if (recoveredRoomId != null && recoveredRoomId != roomId) {
          api.currentRoomId.value = recoveredRoomId;
          await api.loadMessages(recoveredRoomId);
        }
      }
    }
  }

  void _syncFromModels() {
    final meId = _currentUserId();
    final list = api.messages.map((MessageModel m) {
      final fromMe = m.fromMe ?? (meId != null && m.senderId == meId);
      final avatar = _resolveImageUrl(m.senderAvatar ?? '');
      return {
        'fromMe': fromMe,
        'text': m.text,
        'time': m.createdAt?.toIso8601String(),
        'avatar': avatar,
      };
    }).toList();
    messages.assignAll(list);
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Ensure we have a valid room/conversation context
    if (api.currentRoomId.value == null) {
      final args = Get.arguments is Map<String, dynamic>
          ? (Get.arguments as Map<String, dynamic>)
          : <String, dynamic>{};

      final int? roomId = _toInt(args['roomId'] ?? args['conversationId']);
      final int? userId = _toInt(args['userId']) ?? _inferPeerUserId(args);

      int? useRoomId = roomId;
      if (useRoomId == null && userId != null) {
        useRoomId = await api.ensureDmRoomWithUser(userId);
      }

      if (useRoomId != null) {
        api.currentRoomId.value = useRoomId;
        // Load messages to ensure we have the conversation context
        await api.loadMessages(useRoomId);
        _syncFromModels();
      } else {
        Get.snackbar('Error', 'Unable to establish chat context');
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
    textEditingController.clear();

    try {
      final sent = await api.sendMessage(trimmed);
      if (sent == null) {
        _removeLastIfMatches(trimmed);
        Get.snackbar('Message failed', 'Could not send message');
      }
    } catch (e) {
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
        _removeLastIfMatches(trimmed);
        Get.snackbar('Message failed', errText);
      }
    }
  }

  // Emoji picker functions
  void toggleEmojiPicker() {
    showEmojiPicker.value = !showEmojiPicker.value;

    // Unfocus keyboard when showing emoji picker
    if (showEmojiPicker.value) {
      FocusScope.of(Get.context!).unfocus();
    }
  }

  void onEmojiSelected(emoji.Emoji emojiObj) {
    final text = textEditingController.text;
    final selection = textEditingController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emojiObj.emoji,
    );

    textEditingController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emojiObj.emoji.length,
      ),
    );

    textController.value = newText;
  }

  // Image picker functions
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _handleFileSelected(File(image.path), 'image');
      }
    } catch (e) {
      debugPrint('[MessagesController] Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> pickCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        await _handleFileSelected(File(photo.path), 'image');
      }
    } catch (e) {
      debugPrint('[MessagesController] Error taking photo: $e');
      Get.snackbar('Error', 'Failed to take photo: ${e.toString()}');
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        await _handleFileSelected(file, 'document');
      }
    } catch (e) {
      debugPrint('[MessagesController] Error picking document: $e');
      Get.snackbar('Error', 'Failed to pick document: ${e.toString()}');
    }
  }

  Future<void> _handleFileSelected(File file, String type) async {
    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Here you would implement the file upload logic
      // For now, we'll just show a placeholder message
      final fileName = file.path.split('/').last;

      // Close loading dialog
      Get.back();

      // Send message with file info
      final message = type == 'image'
          ? '📷 Image: $fileName'
          : '📄 Document: $fileName';

      await sendMessage(message);

      // TODO: Implement actual file upload to your backend
      // final uploaded = await api.uploadFile(file, type);
      // if (uploaded != null) {
      //   await sendMessage(uploaded['url']);
      // }

      Get.snackbar(
        'Success',
        '$type uploaded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog
      Get.back();

      debugPrint('[MessagesController] Error handling file: $e');
      Get.snackbar('Error', 'Failed to upload $type: ${e.toString()}');
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
      ];
      for (final c in candidates) {
        final id = _toInt(c);
        if (id != null && id != meId) return id;
      }
      // Try participants array
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

  String? _resolveImageUrl(String raw) {
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    if (raw.startsWith('/')) return host + raw;
    if (raw.startsWith('storage/')) return '$host/$raw';
    return '$host/$raw';
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

    if (!Get.isRegistered<FollowService>()) {
      await Get.putAsync<FollowService>(() async => (FollowService()).init());
    }
    final follow = Get.find<FollowService>();
    final ok = await follow.follow(userId, createChatRoom: true);
    if (!ok) return;

    isFollowing.value = true;

    final roomId =
        api.currentRoomId.value ?? await api.ensureDmRoomWithUser(userId);
    if (roomId != null) {
      await api.loadMessages(roomId);
      _syncFromModels();
    }

    _removeLastIfMatches(text);
    final sent = await api.sendMessage(text);
    if (sent == null) {
      Get.snackbar('Message failed', 'Could not send after follow');
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

    if (!Get.isRegistered<FollowService>()) {
      await Get.putAsync<FollowService>(() async => (FollowService()).init());
    }
    final follow = Get.find<FollowService>();
    final ok = await follow.follow(userId, createChatRoom: true);
    if (!ok) return;

    isFollowing.value = true;

    final rid =
        api.currentRoomId.value ?? await api.ensureDmRoomWithUser(userId);
    if (rid != null) {
      await api.loadMessages(rid);
      _syncFromModels();
    }
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  // Optional: Add pull-to-refresh support
  Future<void> refreshMessages() async {
    final rid = api.currentRoomId.value;
    if (rid != null) {
      try {
        await api.loadMessages(rid);
        _syncFromModels();
      } catch (e) {
        debugPrint('[MessagesController] Refresh failed: $e');
      }
    }
  }
}

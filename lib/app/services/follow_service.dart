import 'package:get/get.dart';
import '../data/follow_repository.dart';
import '../data/api_client.dart';
import 'messages_service.dart';
import 'package:flutter/material.dart';

class FollowService extends GetxService {
  late final FollowRepository _repo;
  late final ApiClient _apiClient;

  Future<FollowService> init() async {
    _apiClient = ApiClient();
    _repo = FollowRepository(_apiClient);
    return this;
  }

  Future<bool> follow(int userId, {bool createChatRoom = false}) async {
    try {
      final res = await _repo.followUser(userId);
      final msg = res['message']?.toString() ?? 'Followed';
      _showSnack(msg);

      if (createChatRoom) {
        // Ensure messages service exists
        if (!Get.isRegistered<MessagesService>()) {
          await Get.putAsync<MessagesService>(
            () async => (MessagesService()).init(),
          );
        }
        final messagesService = Get.find<MessagesService>();
        // Backend returns conversation_id on follow; prefer that if present
        int? roomId;
        final convId = res['conversation_id'];
        if (convId is int) roomId = convId;
        if (convId is String) roomId = int.tryParse(convId);

        if (roomId == null) {
          roomId = await messagesService.ensureDmRoomWithUser(userId);
        }

        if (roomId != null) {
          messagesService.currentRoomId.value = roomId;
          // No extra snackbar for room creation; keep UI quiet
        }
      }
      return true;
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  void _showSnack(String msg) {
    Get.snackbar(
      'Info',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}

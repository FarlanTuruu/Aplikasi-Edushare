import 'api_client.dart';

class ChatRepository {
  final ApiClient api;
  ChatRepository(this.api);

  /// Create or get a direct message conversation with a user.
  /// Backend uses Conversation resources; fall back to Rooms if needed.
  Future<Map<String, dynamic>> createOrGetDm(int userId) async {
    try {
      // Preferred: conversations/dm
      return await api.postJson('conversations/dm', {'user_id': userId});
    } catch (_) {
      // Fallback: rooms/dm
      return await api.postJson('rooms/dm', {'user_id': userId});
    }
  }

  /// Get messages for a conversation (or room) by id.
  Future<List<dynamic>> getMessages(int id) async {
    // Prefer rooms endpoint (matches your backend), then fallback to conversations
    try {
      final rooms = await api.getList('rooms/$id/messages');
      if (rooms.isNotEmpty) return rooms;
    } catch (_) {}
    try {
      return await api.getList('conversations/$id/messages');
    } catch (_) {
      return <dynamic>[];
    }
  }

  /// Send a message to conversation (or room) id.
  Future<Map<String, dynamic>> sendMessage(int id, String text) async {
    // Prefer rooms endpoint to match backend, then fallback to conversations
    try {
      return await api.postJson('rooms/$id/messages', {'text': text});
    } catch (_) {
      return await api.postJson('conversations/$id/messages', {'text': text});
    }
  }
}

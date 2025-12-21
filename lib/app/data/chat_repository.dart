import 'api_client.dart';

class ChatRepository {
  final ApiClient api;
  ChatRepository(this.api);

  Future<Map<String, dynamic>> createOrGetDm(int userId) async {
    final res = await api.postJson('rooms/dm', {'user_id': userId});
    return res;
  }

  Future<List<dynamic>> getMessages(int roomId) async {
    // Return a list of message maps (flexible to API shape)
    final list = await api.getList('rooms/$roomId/messages');
    return list;
  }

  Future<Map<String, dynamic>> sendMessage(int roomId, String text) async {
    final res = await api.postJson('rooms/$roomId/messages', {'text': text});
    return res;
  }
}

import 'api_client.dart';

class RoomsRepository {
  final ApiClient api;
  RoomsRepository(this.api);

  Future<List<dynamic>> getRooms() async {
    // GET /rooms (atau /rooms/dm jika hanya DM)
    final list = await api.getList('rooms');
    return list;
  }

  Future<Map<String, dynamic>> createOrGetDm(int userId) async {
    final res = await api.postJson('rooms/dm', {'user_id': userId});
    return res;
  }
}

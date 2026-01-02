import 'api_client.dart';

class CollaborationRepository {
  final ApiClient api;
  CollaborationRepository(this.api);

  Future<List<dynamic>> index() async {
    // Authenticated, owner-specific list
    return await api.getList('collaborations');
  }

  /// Explicitly prefer public endpoints first, without hitting owner-only route
  Future<List<dynamic>> indexPublic() async {
    // Public global list (no auth)
    return await api.getList('public/collaborations');
  }

  Future<Map<String, dynamic>> store(Map<String, dynamic> payload) async {
    return await api.postJson('collaborations', payload);
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return await api.putJson('collaborations/$id', payload);
  }

  Future<void> destroy(String id) async {
    await api.delete('collaborations/$id');
  }
}

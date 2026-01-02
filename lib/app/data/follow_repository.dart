import 'api_client.dart';

class FollowRepository {
  final ApiClient api;
  FollowRepository(this.api);

  Future<Map<String, dynamic>> followUser(int userId) async {
    // POST /follow/{id} with Bearer token
    return await api.postJson('follow/$userId', {});
  }

  Future<Map<String, dynamic>> unfollowUser(int userId) async {
    // Optional: DELETE /follow/{id} if backend supports
    return await api.delete('follow/$userId');
  }
}

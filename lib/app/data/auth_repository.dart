import 'api_client.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository(this.api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Laravel routes: POST /login
    return await api.postJson('login', {'email': email, 'password': password});
  }

  Future<void> logout() async {
    // Laravel routes: POST /logout (auth:sanctum)
    await api.postJson('logout', {});
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    // Laravel routes: POST /register
    return await api.postJson('register', payload);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    // Returns JSON with message and reset_link in development
    return await api.postJson('forgot-password', {'email': email});
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    String? token,
  }) async {
    final body = {
      'email': email,
      'password': newPassword,
      'password_confirmation': newPassword,
      if (token != null) 'token': token,
    };
    return await api.postJson('reset-password', body);
  }
}

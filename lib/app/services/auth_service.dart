import 'package:get/get.dart';
import '../data/auth_repository.dart';
import '../data/api_client.dart';
import '../data/config.dart';

class AuthService extends GetxService {
  late final AuthRepository _repo;
  late final ApiClient _apiClient;
  final isLoggedIn = false.obs;
  final user = Rxn<Map<String, dynamic>>();

  Future<AuthService> init() async {
    _apiClient = ApiClient();
    _repo = AuthRepository(_apiClient);
    return this;
  }

  /// Set API token (dipanggil setelah login berhasil)
  void setApiToken(String? token) {
    _apiClient.setToken(token);
  }

  /// Get current token
  String? getApiToken() {
    return _apiClient.getToken();
  }

  Future<bool> login(String email, String password) async {
    final res = await _repo.login(email, password);
    final token = res['token']?.toString();
    if (token != null && token.isNotEmpty) {
      setApiToken(token);
      user.value = res['user'] as Map<String, dynamic>?;
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  Future<bool> register(Map<String, dynamic> payload) async {
    final res = await _repo.register(payload);
    final token = res['token']?.toString();
    if (token != null && token.isNotEmpty) {
      setApiToken(token);
      user.value = res['user'] as Map<String, dynamic>?;
      isLoggedIn.value = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } finally {
      setApiToken(null);
      user.value = null;
      isLoggedIn.value = false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    final res = await _repo.forgotPassword(email);
    return (res['reset_link']?.toString().isNotEmpty ?? false) ||
        (res['message']?.toString().isNotEmpty ?? false);
  }

  Future<Map<String, dynamic>> forgotPasswordRaw(String email) async {
    return await _repo.forgotPassword(email);
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    String? token,
  }) async {
    final res = await _repo.resetPassword(
      email: email,
      newPassword: newPassword,
      token: token,
    );
    // Laravel returns message on success; treat presence of message as success
    return (res['message']?.toString().isNotEmpty ?? false);
  }
}

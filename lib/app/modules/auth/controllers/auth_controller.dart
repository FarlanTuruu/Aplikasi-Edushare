import 'package:get/get.dart';
import '../../../data/api_client.dart';

class AuthController extends GetxController {
  final isAuthenticated = false.obs;
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.put(ApiClient(), permanent: true);
    isAuthenticated.value = (_api.getToken() ?? '').isNotEmpty;
  }

  Future<void> setToken(String token) async {
    _api.setToken(token);
    isAuthenticated.value = token.isNotEmpty;
  }

  void logout() {
    _api.setToken(null);
    isAuthenticated.value = false;
  }
}

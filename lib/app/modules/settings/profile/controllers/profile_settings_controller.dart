// lib/app/modules/settings/profile/controllers/profile_settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appedushare/app/data/api_client.dart';
import 'package:appedushare/app/data/profile_repository.dart';
import 'package:appedushare/app/data/config.dart';
import 'package:appedushare/app/services/auth_service.dart';

class ProfileSettingsController extends GetxController {
  // Observable variables
  final userName = 'Nanda Adela'.obs;
  final userEmail = 'Nanda@gmail.com'.obs;
  final userLanguage = 'Bahasa Indonesia'.obs;
  final profileImageUrl = 'https://i.pravatar.cc/150?img=47'.obs;
  final userPhone = '081234567890'.obs;
  final isLoading = false.obs;
  final userId = Rx<int?>(null);
  // Used to bust NetworkImage cache when image changes
  final imageVersion = DateTime.now().millisecondsSinceEpoch.obs;

  late final ProfileRepository _repo;

  @override
  void onInit() {
    super.onInit();
    // Ensure ApiClient and repository are available
    final api = Get.isRegistered<ApiClient>()
        ? Get.find<ApiClient>()
        : Get.put(ApiClient(), permanent: true);
    _repo = Get.isRegistered<ProfileRepository>()
        ? Get.find<ProfileRepository>()
        : Get.put(ProfileRepository(api), permanent: true);

    loadUserData();
  }

  Future<void> loadUserData() async {
    await _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    try {
      isLoading.value = true;
      final resp = await _repo.me();
      final data = (resp['data'] is Map<String, dynamic>)
          ? resp['data'] as Map<String, dynamic>
          : resp;

      userName.value = (data['name'] ?? data['username'] ?? userName.value)
          .toString();
      userEmail.value = (data['email'] ?? userEmail.value).toString();
      userPhone.value = (data['phone'] ?? data['telp'] ?? userPhone.value)
          .toString();

      final image = (data['image_url'] ?? data['image'] ?? data['photo'] ?? '')
          .toString();

      // 2. Update version dulu baru update URL-nya untuk memicu UI refresh
      imageVersion.value = DateTime.now().millisecondsSinceEpoch;
      profileImageUrl.value = _resolveImageUrl(image);

      final idVal = data['id'];
      if (idVal is int) {
        userId.value = idVal;
      } else if (idVal is String) {
        userId.value = int.tryParse(idVal);
      }
    } catch (e) {
      Get.snackbar(
        'Info',
        'Gagal memuat profil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk update profile dari Edit Profile
  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String imageUrl,
  }) {
    userName.value = name;
    userEmail.value = email;
    userPhone.value = phone;
    imageVersion.value = DateTime.now().millisecondsSinceEpoch;
    profileImageUrl.value = imageUrl;
  }

  void navigateToEditProfile() {
    Get.toNamed('/settings/edit_profile');
  }

  void navigateToSaveNotes() {
    Get.toNamed('/settings/save-notes');
  }

  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Apakah Anda yakin ingin keluar?',
      textConfirm: 'Ya',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF5B2C91),
      cancelTextColor: const Color(0xFF5B2C91),
      onConfirm: () async {
        // Pastikan AuthService tersedia lalu logout untuk clear token & sesi
        if (!Get.isRegistered<AuthService>()) {
          await Get.putAsync<AuthService>(() async => (AuthService()).init());
        }
        final auth = Get.find<AuthService>();
        await auth.logout();
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Pastikan fungsi ini seperti ini:
  String _resolveImageUrl(String raw) {
    if (raw.isEmpty)
      return 'https://i.pravatar.cc/150?img=47'; // Default fallback
    final s = raw.trim();

    // Jika URL dari server sudah ada http/https
    if (s.startsWith('http://') || s.startsWith('https://')) {
      final sep = s.contains('?') ? '&' : '?';
      return '$s${sep}v=${imageVersion.value}';
    }

    // Logic storage Laravel
    final base = apiBaseUrl; // Pastikan variabel ini benar
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;

    // Hilangkan slash awal jika ada biar tidak double slash
    final cleanPath = s.startsWith('/') ? s.substring(1) : s;

    return '$host/storage/$cleanPath?v=${imageVersion.value}';
  }
}

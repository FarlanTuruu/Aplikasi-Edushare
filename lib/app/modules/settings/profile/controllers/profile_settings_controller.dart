// lib/app/modules/settings/profile/controllers/profile_settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsController extends GetxController {
  // Observable variables
  final userName = 'Nanda Adela'.obs;
  final userEmail = 'Nanda@gmail.com'.obs;
  final userLanguage = 'Bahasa Indonesia'.obs;
  final profileImageUrl = 'https://i.pravatar.cc/150?img=47'.obs;
  final userPhone = '081234567890'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    // TODO: Load data dari local storage atau API
    // Contoh:
    // userName.value = await StorageService.getUserName();
    // userEmail.value = await StorageService.getUserEmail();
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
    profileImageUrl.value = imageUrl;

    // TODO: Save to local storage
    // StorageService.saveUserData({...});
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
      onConfirm: () {
        // TODO: Clear user session/token
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}

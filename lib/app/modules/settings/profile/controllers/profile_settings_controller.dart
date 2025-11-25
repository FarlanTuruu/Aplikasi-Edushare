// lib/app/modules/settings/profile/controllers/profile_settings_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsController extends GetxController {
  // Observable variables
  final userName = 'Nanda Adela'.obs;
  final userEmail = 'Nanda@gmail.com'.obs;
  final userLanguage = 'Bahasa Indonesia'.obs;
  final profileImageUrl = 'https://i.pravatar.cc/150?img=47'.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize data atau load dari local storage
    loadUserData();
  }

  void loadUserData() {
    // TODO: Load data dari local storage atau API
    // Contoh:
    // userName.value = await StorageService.getUserName();
    // userEmail.value = await StorageService.getUserEmail();
  }

  void navigateToEditProfile() {
    // Navigate ke halaman Edit Profile
    Get.toNamed('/settings/profile/edit');
  }

  void navigateToSaveNotes() {
    // Navigate ke halaman Save Notes
    Get.toNamed('/settings/save-notes');
  }

  void logout() {
    // Show confirmation dialog
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
        // Contoh:
        // StorageService.clearUserData();
        // AuthService.logout();

        Get.back(); // Close dialog

        // Navigate to login page
        Get.offAllNamed('/login');
      },
    );
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

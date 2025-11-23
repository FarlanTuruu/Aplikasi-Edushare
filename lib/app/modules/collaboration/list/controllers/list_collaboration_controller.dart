import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListCollaborationController extends GetxController {
  // Observable list of collaborations
  final collaborations = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCollaborations();
  }

  // ============= DATA METHODS =============

  // Load collaborations from API or local storage
  void loadCollaborations() {
    isLoading.value = true;

    // Simulasi API Call dengan data sesuai gambar
    Future.delayed(const Duration(seconds: 1), () {
      collaborations.assignAll([
        {
          'id': 1,
          'title': 'Rangkuman Praskripsi',
          'date': '24',
          'day': 'Sep',
          'createdAt': '2024-09-24',
        },
        {
          'id': 2,
          'title': 'Rangkuman RI',
          'date': '24',
          'day': 'Sep',
          'createdAt': '2024-09-24',
        },
        {
          'id': 3,
          'title': 'Rangkuman RK',
          'date': '24',
          'day': 'Sep',
          'createdAt': '2024-09-24',
        },
      ]);
      isLoading.value = false;
    });
  }

  // Edit collaboration
  void editCollaboration(int index) {
    final item = collaborations[index];
    Get.snackbar(
      'Edit',
      'Mengedit ${item['title']}',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(20),
    );
  }

  // Delete collaboration
  void deleteCollaboration(int index) {
    final item = collaborations[index];
    Get.defaultDialog(
      title: 'Hapus',
      middleText: 'Yakin ingin menghapus "${item['title']}"?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        collaborations.removeAt(index);
        Get.back();
        Get.snackbar(
          'Sukses',
          'Data berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(20),
        );
      },
    );
  }

  // ============= NAVIGATION METHODS =============
  void goToProfile() => print("Navigate to Profile");
  void goToSettings() => print("Navigate to Settings");
  void navigateToHome() => print("Navigate to Home");
  void navigateToChat() => print("Navigate to Chat");
  void navigateToVoice() => print("Navigate to Voice");
  void openAddMenu() => print("Open Add Menu");
  void openMoreMenu() => print("Open More Menu");
}

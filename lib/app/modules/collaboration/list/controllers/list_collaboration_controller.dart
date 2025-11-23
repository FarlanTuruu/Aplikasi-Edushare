// File 1: /lib/app/modules/collaboration/list/controllers/list_collaboration_controller.dart
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

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ============= DATA METHODS =============

  // Load collaborations from API or local storage
  void loadCollaborations() {
    isLoading.value = true;

    // TODO: Implement actual API call
    // Example data - replace with API call
    Future.delayed(const Duration(seconds: 1), () {
      collaborations.addAll([
        {
          'id': 1,
          'title': 'Rangkuman Praskripsj',
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
    if (index < 0 || index >= collaborations.length) return;

    final collaboration = collaborations[index];
    // TODO: Navigate to edit collaboration page
    // Get.toNamed(Routes.EDIT_COLLABORATION, arguments: collaboration);
    Get.snackbar('Edit', 'Editing: ${collaboration['title']}');
  }

  // Delete collaboration
  void deleteCollaboration(int index) {
    if (index < 0 || index >= collaborations.length) return;

    final collaboration = collaborations[index];

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Collaboration'),
        content: Text(
          'Are you sure you want to delete "${collaboration['title']}"?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              collaborations.removeAt(index);
              Get.back();
              Get.snackbar('Success', '${collaboration['title']} deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Add new collaboration
  void addCollaboration(Map<String, dynamic> collaboration) {
    collaborations.add(collaboration);
    Get.snackbar('Success', 'Collaboration added successfully');
  }

  // ============= NAVIGATION METHODS =============

  // Go to profile
  void goToProfile() {
    // TODO: Navigate to profile page
    // Get.toNamed(Routes.PROFILE);
    Get.snackbar('Info', 'Go to Profile');
  }

  // Go to settings
  void goToSettings() {
    // TODO: Navigate to settings page
    // Get.toNamed(Routes.SETTINGS);
    Get.snackbar('Info', 'Go to Settings');
  }

  // Open add menu
  void openAddMenu() {
    // TODO: Show bottom sheet or dialog for adding new collaboration
    Get.snackbar('Info', 'Open Add Menu');
  }

  // Open more menu
  void openMoreMenu() {
    // TODO: Show bottom sheet for more options
    Get.snackbar('Info', 'Open More Menu');
  }

  // Navigate to home
  void navigateToHome() {
    // TODO: Navigate to home page
    // Get.toNamed(Routes.HOME);
    Get.snackbar('Navigation', 'Go to Home');
  }

  // Navigate to chat
  void navigateToChat() {
    // TODO: Navigate to chat page
    // Get.toNamed(Routes.CHAT);
    Get.snackbar('Navigation', 'Go to Chat');
  }

  // Navigate to voice
  void navigateToVoice() {
    // TODO: Navigate to voice page
    // Get.toNamed(Routes.VOICE);
    Get.snackbar('Navigation', 'Go to Voice');
  }

  // ============= UTILITY METHODS =============

  // Get total collaborations
  int get totalCollaborations => collaborations.length;

  // Search collaborations
  List<Map<String, dynamic>> searchCollaborations(String query) {
    return collaborations
        .where(
          (collaboration) =>
              collaboration['title'].toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              collaboration['createdAt'].toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }

  // Sort collaborations by date
  void sortByDate({bool ascending = false}) {
    collaborations.sort((a, b) {
      final dateA = DateTime.parse(a['createdAt']);
      final dateB = DateTime.parse(b['createdAt']);
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  }

  // Filter collaborations by month
  List<Map<String, dynamic>> filterByMonth(int month, int year) {
    return collaborations.where((collaboration) {
      final date = DateTime.parse(collaboration['createdAt']);
      return date.month == month && date.year == year;
    }).toList();
  }
}

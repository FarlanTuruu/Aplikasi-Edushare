// ==================== CONTROLLER ====================
// File: create_notes_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class CreateNotesController extends GetxController {
  // Tab selection
  final selectedTab = 0.obs; // 0: Draft, 1: Archived, 2: Scheduled

  // Text Controllers
  final mataKuliahController = TextEditingController();
  final judulCatatanController = TextEditingController();
  final tanggalController = TextEditingController();
  final deskripsiController = TextEditingController();

  // File
  final selectedFileName = ''.obs;

  @override
  void onClose() {
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      selectedFileName.value = result.files.single.name;
    }
  }

  void saveDraft() {
    // Implementasi save draft
    Get.snackbar(
      'Draft',
      'Catatan disimpan sebagai draft',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void cancel() {
    // Clear all fields or navigate back
    mataKuliahController.clear();
    judulCatatanController.clear();
    tanggalController.clear();
    deskripsiController.clear();
    selectedFileName.value = '';
  }

  void upload() {
    // Validasi
    if (mataKuliahController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Mata kuliah harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (judulCatatanController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Judul catatan harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Implementasi upload
    Get.snackbar(
      'Success',
      'Catatan berhasil diunggah',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}

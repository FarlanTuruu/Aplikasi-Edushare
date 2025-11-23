import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCollaborationController extends GetxController {
  final mataKuliahController = TextEditingController();
  final judulCatatanController = TextEditingController();
  final deskripsiController = TextEditingController();
  final linkDocsController = TextEditingController();

  @override
  void onClose() {
    mataKuliahController.dispose();
    judulCatatanController.dispose();
    deskripsiController.dispose();
    linkDocsController.dispose();
    super.onClose();
  }

  void submitCollaboration() {
    if (mataKuliahController.text.isEmpty ||
        judulCatatanController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Harap isi semua field',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    // TODO: Implement logic simpan data
    Get.back(); // Kembali ke halaman sebelumnya
    Get.snackbar(
      'Sukses',
      'Catatan berhasil dibuat',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void goBack() {
    Get.back();
  }
}

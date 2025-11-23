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
    final mataKuliah = mataKuliahController.text;
    final judulCatatan = judulCatatanController.text;
    final deskripsi = deskripsiController.text;
    final linkDocs = linkDocsController.text;

    if (mataKuliah.isEmpty ||
        judulCatatan.isEmpty ||
        deskripsi.isEmpty ||
        linkDocs.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // TODO: Implement submission logic
    Get.snackbar('Success', 'Collaboration created successfully');
  }

  void uploadFile() {
    submitCollaboration();
  }
}

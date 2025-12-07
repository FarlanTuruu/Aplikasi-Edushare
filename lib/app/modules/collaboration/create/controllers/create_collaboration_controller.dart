import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../collaboration/list/controllers/list_collaboration_controller.dart';
import '../../../../routes/app_pages.dart';

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
    // Pastikan ListCollaborationController terdaftar dan tidak dihapus saat navigasi
    if (!Get.isRegistered<ListCollaborationController>()) {
      Get.put(ListCollaborationController(), permanent: true);
    }
    final listController = Get.find<ListCollaborationController>();

    final now = DateTime.now();
    final dateStr = now.day.toString().padLeft(2, '0');
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthStr = months[now.month - 1];
    final createdAtStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final newItem = {
      'id': (listController.collaborations.isEmpty
          ? 1
          : (listController.collaborations.last['id'] ?? 0) + 1),
      'title': judulCatatanController.text.trim(),
      'date': dateStr,
      'day': monthStr,
      'createdAt': createdAtStr,
      // Optional fields if needed later
      'mataKuliah': mataKuliahController.text.trim(),
      'deskripsi': deskripsiController.text.trim(),
      'link': linkDocsController.text.trim(),
    };

    listController.collaborations.add(newItem);

    // Bersihkan form setelah submit
    mataKuliahController.clear();
    judulCatatanController.clear();
    deskripsiController.clear();
    linkDocsController.clear();

    // Navigasi ke halaman list agar terlihat
    Get.offNamed(Routes.COLLAB_LIST);

    Get.snackbar(
      'Sukses',
      'Catatan dummy berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void goBack() {
    Get.back();
  }
}

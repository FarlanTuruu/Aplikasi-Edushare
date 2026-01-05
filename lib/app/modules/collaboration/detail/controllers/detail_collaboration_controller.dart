import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailCollaborationController extends GetxController {
  final isLoading = false.obs;

  // Data kolaborasi yang diterima dari List (Map sederhana)
  final collab = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      collab.assignAll(args);
    }
  }

  // Aksi: Bagikan (placeholder UI)
  void shareCollab() {
    final title = collab['title']?.toString() ?? 'Catatan';
    Get.snackbar(
      'Share',
      'Berbagi kolaborasi: $title',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.share, color: Colors.white),
    );
  }

  // Buka link dokumen jika tersedia
  Future<void> openLink() async {
    final link = (collab['link'] ?? '').toString();
    if (link.isEmpty) {
      Get.snackbar(
        'Info',
        'Tidak ada link dokumen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri == null) {
      Get.snackbar(
        'Error',
        'Link tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        Get.snackbar(
          'Error',
          'Gagal membuka link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

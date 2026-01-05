import 'package:appedushare/app/data/api_client.dart';
import 'package:appedushare/app/data/collaboration_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../list/controllers/list_collaboration_controller.dart';

class EditCollaborationController extends GetxController {
  final mataKuliahController = TextEditingController();
  final judulCatatanController = TextEditingController();
  final deskripsiController = TextEditingController();
  final linkDocsController = TextEditingController();

  final isLoading = false.obs;
  String? collabId;
  String? createdAtDate; // yyyy-MM-dd required by backend

  late final CollaborationRepository _repo;
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    // Ensure ApiClient
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    _api = Get.find<ApiClient>();
    _repo = CollaborationRepository(_api);

    // Prefill from arguments
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      collabId = (args['id'] ?? '').toString().isEmpty
          ? null
          : (args['id'] ?? '').toString();
      mataKuliahController.text =
          (args['mataKuliah'] ?? args['mata_kuliah'] ?? '').toString();
      judulCatatanController.text = (args['title'] ?? args['judul'] ?? '')
          .toString();
      deskripsiController.text =
          (args['deskripsi'] ?? args['description'] ?? '').toString();
      linkDocsController.text = (args['link'] ?? args['link_docs'] ?? '')
          .toString();
      // Normalize created_at_date
      final argCreated = (args['createdAt'] ?? args['created_at_date'] ?? '')
          .toString();
      if (argCreated.isNotEmpty) {
        // Try parse any date and format to yyyy-MM-dd
        try {
          final dt = DateTime.parse(argCreated);
          createdAtDate =
              '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
                  .toString();
        } catch (_) {
          createdAtDate = argCreated; // assume already yyyy-MM-dd
        }
      } else {
        final now = DateTime.now();
        createdAtDate =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      }
    }
  }

  @override
  void onClose() {
    mataKuliahController.dispose();
    judulCatatanController.dispose();
    deskripsiController.dispose();
    linkDocsController.dispose();
    super.onClose();
  }

  Future<void> updateCollaboration() async {
    if ((collabId ?? '').isEmpty) {
      Get.snackbar(
        'Error',
        'ID data tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (mataKuliahController.text.trim().isEmpty ||
        judulCatatanController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi',
        'Harap isi Mata Kuliah dan Judul',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    // Require token for update
    if ((_api.getToken() ?? '').isEmpty) {
      Get.snackbar(
        'Autentikasi',
        'Silakan login terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Ensure created_at_date is present (yyyy-MM-dd)
      if ((createdAtDate ?? '').toString().trim().isEmpty) {
        final now = DateTime.now();
        createdAtDate =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      }

      // Sanitize link per backend rule (nullable|url)
      String rawLink = linkDocsController.text.trim();
      String? safeLink;
      if (rawLink.isEmpty) {
        safeLink = null; // send null instead of empty string
      } else {
        if (!rawLink.startsWith('http://') && !rawLink.startsWith('https://')) {
          rawLink = 'https://$rawLink';
        }
        safeLink = rawLink;
      }

      final payload = {
        'title': judulCatatanController.text.trim(),
        'mata_kuliah': mataKuliahController.text.trim(),
        'description': deskripsiController.text.trim(),
        'link': safeLink,
        'created_at_date': createdAtDate,
      };
      await _repo.update(collabId!, payload);

      // Refresh list
      if (!Get.isRegistered<ListCollaborationController>()) {
        Get.put(ListCollaborationController(), permanent: true);
      }
      final listCtrl = Get.find<ListCollaborationController>();
      await listCtrl.loadCollaborations(force: true);

      Get.back();
      Get.snackbar(
        'Sukses',
        'Perubahan berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

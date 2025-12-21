import 'package:appedushare/app/data/api_client.dart';
import 'package:appedushare/app/data/collaboration_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../collaboration/list/controllers/list_collaboration_controller.dart';
import '../../../../routes/app_pages.dart';

class CreateCollaborationController extends GetxController {
  final mataKuliahController = TextEditingController();
  final judulCatatanController = TextEditingController();
  final deskripsiController = TextEditingController();
  final linkDocsController = TextEditingController();

  late final CollaborationRepository _repo;
  late final ApiClient _api;

  @override
  void onClose() {
    mataKuliahController.dispose();
    judulCatatanController.dispose();
    deskripsiController.dispose();
    linkDocsController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Gunakan instance ApiClient global jika sudah ada
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    _api = Get.find<ApiClient>();
    // Repo tidak diregister untuk menghindari instance dengan ApiClient berbeda
    _repo = CollaborationRepository(_api);
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
    // Token guard: pastikan user telah login
    if ((_api.getToken() ?? '').isEmpty) {
      Get.snackbar(
        'Autentikasi',
        'Silakan login terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      // TODO: arahkan ke halaman login jika tersedia
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

    // Sesuaikan dengan Laravel Sanctum API (snake_case)
    final payload = {
      'title': judulCatatanController.text.trim(),
      'mata_kuliah': mataKuliahController.text.trim(),
      'description': deskripsiController.text.trim(),
      'link': linkDocsController.text.trim(),
      'created_at_date': createdAtStr,
    };

    _storeToApi(payload, listController, dateStr, monthStr);

    // Bersihkan form setelah submit
    mataKuliahController.clear();
    judulCatatanController.clear();
    deskripsiController.clear();
    linkDocsController.clear();

    // Navigasi ke halaman list agar terlihat
    // Navigasi akan dilakukan setelah API sukses melalui _storeToApi
  }

  void goBack() {
    Get.back();
  }

  Future<void> _storeToApi(
    Map<String, dynamic> payload,
    ListCollaborationController listController,
    String dateStr,
    String monthStr,
  ) async {
    try {
      final created = await _repo.store(payload);
      // Setelah sukses, refresh list dari server agar data yang tampil adalah data DB sebenarnya
      await listController.loadCollaborations(force: true);

      Get.offNamed(Routes.COLLAB_LIST);
      Get.snackbar(
        'Sukses',
        'Catatan berhasil diunggah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upload: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}

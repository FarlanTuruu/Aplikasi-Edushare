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

  // Helper function untuk extract string dengan null-safety
  String safeString(dynamic value) {
    if (value == null) return '';
    if (value.toString() == 'null') return '';
    return value.toString().trim();
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure ApiClient
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    _api = Get.find<ApiClient>();
    _repo = CollaborationRepository(_api);

    // Prefill from arguments dengan null-safety yang lebih baik
    final args = Get.arguments;

    print('=== EDIT CONTROLLER INIT ===');
    print('Arguments type: ${args.runtimeType}');
    print('Arguments: $args');

    if (args is Map<String, dynamic>) {
      try {
        // Extract ID dengan null-safety
        final idValue = args['id'];
        if (idValue != null &&
            idValue.toString().isNotEmpty &&
            idValue.toString() != 'null') {
          collabId = idValue.toString();
        }

        // Extract dan set semua field dengan null-safety
        mataKuliahController.text = safeString(
          args['mataKuliah'] ?? args['mata_kuliah'],
        );

        judulCatatanController.text = safeString(
          args['title'] ?? args['judul'],
        );

        deskripsiController.text = safeString(
          args['deskripsi'] ?? args['description'],
        );

        linkDocsController.text = safeString(args['link'] ?? args['link_docs']);

        // Normalize created_at_date dengan null-safety
        final argCreated = safeString(
          args['createdAt'] ?? args['created_at_date'] ?? args['created_at'],
        );

        if (argCreated.isNotEmpty) {
          // Try parse any date and format to yyyy-MM-dd
          try {
            final dt = DateTime.parse(argCreated);
            createdAtDate =
                '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
          } catch (e) {
            print('Date parse error: $e');
            // assume already yyyy-MM-dd or use today
            if (argCreated.contains('-') && argCreated.length >= 10) {
              createdAtDate = argCreated.substring(0, 10);
            } else {
              final now = DateTime.now();
              createdAtDate =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
            }
          }
        } else {
          final now = DateTime.now();
          createdAtDate =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        }

        print('✓ Fields initialized:');
        print('  - ID: $collabId');
        print('  - Title: ${judulCatatanController.text}');
        print('  - Mata Kuliah: ${mataKuliahController.text}');
        print('  - Deskripsi: ${deskripsiController.text}');
        print('  - Link: ${linkDocsController.text}');
        print('  - Created At: $createdAtDate');
      } catch (e) {
        print('✗ Error initializing fields: $e');
        Get.snackbar(
          'Error',
          'Gagal memuat data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } else {
      print('✗ Invalid arguments type');
      Get.snackbar(
        'Error',
        'Data tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    print('============================');
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
    print('=== UPDATE COLLABORATION ===');
    print('Collab ID: $collabId');

    // Validasi ID
    if (collabId == null || collabId!.isEmpty || collabId == 'null') {
      Get.snackbar(
        'Error',
        'ID data tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi field required
    final mataKuliah = mataKuliahController.text.trim();
    final judul = judulCatatanController.text.trim();

    if (mataKuliah.isEmpty || judul.isEmpty) {
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
      if (createdAtDate == null || createdAtDate!.isEmpty) {
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
        'title': judul,
        'mata_kuliah': mataKuliah,
        'description': deskripsiController.text.trim(),
        'link': safeLink,
        'created_at_date': createdAtDate,
      };

      print('Payload: $payload');

      await _repo.update(collabId!, payload);

      print('✓ Update successful');

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
      print('✗ Update error: $e');
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
    print('===========================');
  }
}

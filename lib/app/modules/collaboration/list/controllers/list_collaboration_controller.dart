import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appedushare/app/data/api_client.dart';
import 'package:appedushare/app/data/collaboration_repository.dart';

class ListCollaborationController extends GetxController {
  // Observable list of collaborations
  final collaborations = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxString('');

  late final CollaborationRepository _repo;
  late final ApiClient _api;

  @override
  void onInit() {
    super.onInit();
    // Gunakan instance ApiClient global bila sudah ada, hindari duplikasi
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    _api = Get.find<ApiClient>();
    // Jangan register Repo ke GetX untuk menghindari instance dengan dependency berbeda
    _repo = CollaborationRepository(_api);
    loadCollaborations();
  }

  // ============= DATA METHODS =============

  // Load collaborations from API or local storage
  Future<void> loadCollaborations({bool force = false}) async {
    // Jika tidak force dan data sudah ada, hindari fetch ulang otomatis
    if (!force && collaborations.isNotEmpty) return;
    // Jika belum login (tidak ada token), tampilkan info dan hentikan
    if ((_api.getToken() ?? '').isEmpty) {
      errorMessage.value = 'Silakan login terlebih dahulu';
      Get.snackbar(
        'Autentikasi',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await _repo.index();
      // Map hasil API ke struktur yang dipakai UI
      final mapped = list.map<Map<String, dynamic>>((item) {
        final map = item as Map<String, dynamic>;
        final createdAt =
            map['created_at_date']?.toString() ??
            map['createdAt']?.toString() ??
            map['created_at']?.toString() ??
            '';
        DateTime? dt;
        try {
          if (createdAt.isNotEmpty) dt = DateTime.parse(createdAt);
        } catch (_) {}
        final dayStr = dt != null
            ? [
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
              ][dt.month - 1]
            : (map['day']?.toString() ?? '');
        final dateStr = dt != null
            ? dt.day.toString().padLeft(2, '0')
            : (map['date']?.toString() ?? '');
        return {
          'id': map['id'] ?? map['uuid'] ?? map['ID'],
          'title': map['title'] ?? map['judul'] ?? '',
          'date': dateStr,
          'day': dayStr,
          'createdAt': createdAt,
          'mataKuliah': map['mata_kuliah'] ?? map['mataKuliah'],
          'deskripsi': map['description'] ?? map['deskripsi'],
          'link': map['link'] ?? map['link_docs'],
        };
      }).toList();
      collaborations.assignAll(mapped);
    } catch (e) {
      errorMessage.value = e.toString();
      // Tangani pesan 401 khusus
      final isUnauth =
          errorMessage.value.contains('401') ||
          errorMessage.value.toLowerCase().contains('unauthenticated');
      Get.snackbar(
        isUnauth ? 'Autentikasi' : 'Error',
        isUnauth
            ? 'Silakan login terlebih dahulu'
            : 'Gagal memuat data: ${errorMessage.value}',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    } finally {
      isLoading.value = false;
    }
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
        _deleteFromApi(item, index);
      },
    );
  }

  Future<void> _deleteFromApi(Map<String, dynamic> item, int index) async {
    try {
      final id = (item['id'] ?? '').toString();
      if (id.isEmpty) throw Exception('ID tidak ditemukan');
      await _repo.destroy(id);
      collaborations.removeAt(index);
      Get.back();
      Get.snackbar(
        'Sukses',
        'Data berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal menghapus: $e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    }
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

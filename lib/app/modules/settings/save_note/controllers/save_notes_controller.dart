// lib/app/modules/settings/save_note/controllers/save_notes_controller.dart

import 'package:get/get.dart';

class SaveNotesController extends GetxController {
  // Observable list of saved notes
  final savedNotes = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedNotes();
  }

  // ============================================================
  // LOAD SAVED NOTES
  // ============================================================
  Future<void> loadSavedNotes() async {
    try {
      isLoading.value = true;

      // Simulasi loading
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Load dari API atau local storage
      // final response = await ApiService.getSavedNotes();
      // savedNotes.value = response.data;

      // Dummy data untuk testing
      savedNotes.value = [
        {
          'id': '1',
          'author': 'Alfi Aulia',
          'authorImage': 'https://i.pravatar.cc/150?img=5',
          'title':
              'Catatan Untuk Mata Kuliah Pengembangan Industri 4.0 Untuk Semester 5',
          'thumbnail':
              'https://cdn.pixabay.com/photo/2016/11/19/14/00/code-1839406_1280.jpg',
          'date': '2024-01-15',
        },
        {
          'id': '2',
          'author': 'Alfi Aulia',
          'authorImage': 'https://i.pravatar.cc/150?img=5',
          'title':
              'Catatan Untuk Mata Kuliah Pengembangan Industri 4.0 Untuk Semester 5',
          'thumbnail':
              'https://cdn.pixabay.com/photo/2015/09/17/17/25/graduation-944312_1280.jpg',
          'date': '2024-01-14',
        },
        {
          'id': '3',
          'author': 'Alfi Aulia',
          'authorImage': 'https://i.pravatar.cc/150?img=5',
          'title':
              'Catatan Untuk Mata Kuliah Pengembangan Industri 4.0 Untuk Semester 5',
          'thumbnail':
              'https://cdn.pixabay.com/photo/2016/11/29/06/15/plans-1867745_1280.jpg',
          'date': '2024-01-13',
        },
        {
          'id': '4',
          'author': 'Alfi Aulia',
          'authorImage': 'https://i.pravatar.cc/150?img=5',
          'title':
              'Catatan Untuk Mata Kuliah Pengembangan Industri 4.0 Untuk Semester 5',
          'thumbnail':
              'https://cdn.pixabay.com/photo/2017/08/30/01/05/milky-way-2695569_1280.jpg',
          'date': '2024-01-12',
        },
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat catatan tersimpan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // OPEN NOTE DETAIL
  // ============================================================
  void openNoteDetail(Map<String, dynamic> note) {
    // TODO: Navigate to note detail page
    Get.toNamed('/notes/detail', arguments: note);

    // Temporary snackbar
    Get.snackbar(
      'Info',
      'Membuka: ${note['title']}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ============================================================
  // UNSAVE NOTE
  // ============================================================
  Future<void> unsaveNote(String noteId) async {
    try {
      // TODO: Call API to unsave
      // await ApiService.unsaveNote(noteId);

      // Remove from list
      savedNotes.removeWhere((note) => note['id'] == noteId);

      Get.snackbar(
        'Sukses',
        'Catatan berhasil dihapus dari simpanan',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus catatan',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // REFRESH DATA
  // ============================================================
  Future<void> refreshData() async {
    await loadSavedNotes();
  }
}

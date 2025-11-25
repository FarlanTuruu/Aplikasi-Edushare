import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class ArchiveNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final archivedList = <NoteModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔧 Listen langsung ke archivedNotes dari service
    ever(notesService.archivedNotes, (List<NoteModel> archives) {
      archivedList.value = archives.toList();
      print('✅ Archive list updated: ${archives.length} archives');
    });

    // 🔧 Set initial value
    archivedList.value = notesService.archivedNotes.toList();
  }

  Future<void> unarchiveNote(String noteId) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      notesService.unarchiveNote(noteId);

      Get.snackbar(
        'Success',
        'Catatan berhasil dikembalikan ke list',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengembalikan catatan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteArchive(String noteId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      notesService.deleteNote(noteId, isArchived: true);

      Get.snackbar(
        'Success',
        'Arsip berhasil dihapus permanen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus arsip: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void editArchive(String noteId) {
    final note = archivedList.firstWhere((n) => n.id == noteId);
    Get.toNamed('/notes/create', arguments: note.toMap());
  }

  Future<void> refreshArchives() async {
    archivedList.value = notesService.archivedNotes.toList();
  }
}

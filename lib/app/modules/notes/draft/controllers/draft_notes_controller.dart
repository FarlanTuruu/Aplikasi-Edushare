import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class DraftNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final draftList = <NoteModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔧 FIX: Gunakan ever() listener, bukan bindStream()
    ever(notesService.draftNotes, (List<NoteModel> drafts) {
      draftList.value = drafts.toList();
      print('✅ Draft list updated: ${drafts.length} drafts');
    });

    // 🔧 FIX: Set initial value
    draftList.value = notesService.draftNotes.toList();
  }

  Future<void> publishDraft(String noteId) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      notesService.publishDraft(noteId);

      Get.snackbar(
        'Success',
        'Draft berhasil dipublikasikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mempublikasikan draft: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDraft(String noteId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      notesService.deleteNote(noteId, isDraft: true);

      Get.snackbar(
        'Success',
        'Draft berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus draft: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void editDraft(String noteId) {
    final note = draftList.firstWhere((n) => n.id == noteId);
    Get.toNamed('/notes/create', arguments: note.toMap());
  }

  // 🔧 FIX: Tambahkan refresh method
  Future<void> refreshDrafts() async {
    draftList.value = notesService.draftNotes.toList();
  }
}

// lib/app/modules/settings/save_note/controllers/save_notes_controller.dart

import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../data/config.dart';

class SaveNotesController extends GetxController {
  // Observable list of saved notes
  final savedNotes = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure NotesService is available
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }
    loadSavedNotes();
  }

  // ============================================================
  // LOAD SAVED NOTES
  // ============================================================
  Future<void> loadSavedNotes() async {
    try {
      isLoading.value = true;
      final notesService = Get.find<NotesService>();
      await notesService.refreshAll();
      final saved = notesService.savedNotes.toList();

      // Map NoteModel -> view map shape
      final mapped = saved.map<Map<String, dynamic>>((note) {
        final authorName = note.authorName ?? 'Unknown';
        final authorImg = _resolveImageUrl(note.authorImage ?? '');
        // Thumbnail: use note file if image, else placeholder
        String thumb = 'https://picsum.photos/seed/saved-${note.id}/400/200';
        final fn = note.fileName;
        if (fn != null && fn.isNotEmpty) {
          final lower = fn.toLowerCase();
          final isImage =
              lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png') ||
              lower.endsWith('.gif') ||
              lower.endsWith('.webp');
          if (isImage) {
            thumb = _buildFileUrl(fn);
          }
        }
        return {
          'id': note.id,
          'author': authorName,
          'authorImage': authorImg.isNotEmpty
              ? authorImg
              : 'https://i.pravatar.cc/150?img=47',
          'title': note.title,
          'thumbnail': thumb,
          'date': note.fullDate,
        };
      }).toList();

      savedNotes.assignAll(mapped);
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
      if (!Get.isRegistered<NotesService>()) {
        Get.put(NotesService(), permanent: true);
      }
      final notesService = Get.find<NotesService>();
      await notesService.unsaveNote(noteId);
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

  String _resolveImageUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http')) return raw;
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    if (raw.startsWith('/')) return host + raw;
    if (raw.startsWith('storage/')) return '$host/$raw';
    return '$host/$raw';
  }

  String _buildFileUrl(String fileName) {
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    return '$host/storage/$fileName';
  }
}

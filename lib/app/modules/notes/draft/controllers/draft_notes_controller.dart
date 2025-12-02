// File 3: draft_notes_controller.dart
// ============================================================

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

    ever(notesService.draftNotes, (List<NoteModel> drafts) {
      draftList.value = drafts.toList();
      print('✅ Draft list updated: ${drafts.length} drafts');
    });

    draftList.value = notesService.draftNotes.toList();
  }

  Future<void> publishDraft(String noteId) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      final note = draftList.firstWhere((n) => n.id == noteId);
      notesService.publishDraft(noteId);

      // 🎉 POP-UP DIALOG untuk Publish Draft
      _showSuccessDialog(
        title: '✅ Draft Dipublikasikan!',
        message:
            'Draft "${note.title}" berhasil dipublikasikan dan sekarang tersedia di List Notes.',
        icon: Icons.check_circle,
        color: Colors.green,
        actionText: 'Lihat di List Notes',
        onActionPressed: () {
          Get.back();
          Get.toNamed('/notes/list');
        },
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
    final note = draftList.firstWhere((n) => n.id == noteId);

    // Konfirmasi dialog sebelum hapus
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚠️ Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus draft "${note.title}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog konfirmasi

              try {
                await Future.delayed(const Duration(milliseconds: 200));
                notesService.deleteNote(noteId, isDraft: true);

                // 🎉 POP-UP DIALOG untuk Delete Archive
                _showSuccessDialog(
                  title: '🗑️ Draft Dihapus Permanen',
                  message:
                      'Draft "${note.title}" telah dihapus secara permanen dan tidak dapat dipulihkan.',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  actionText: 'Tutup',
                  // 🔧 FIXED: Redirect ke archive page ketika tekan "Tutup"
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.offAllNamed('/notes/draft'); // Redirect & clear stack
                  },
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void editDraft(String noteId) {
    final note = draftList.firstWhere((n) => n.id == noteId);
    Get.toNamed('/notes/edit', arguments: note.toMap());
  }

  Future<void> refreshDrafts() async {
    draftList.value = notesService.draftNotes.toList();
  }

  // 🎨 CUSTOM SUCCESS DIALOG
  void _showSuccessDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

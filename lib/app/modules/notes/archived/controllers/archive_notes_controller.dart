import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class ArchiveNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final archivedList = <NoteModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever(notesService.archivedNotes, (List<NoteModel> archives) {
      archivedList.value = archives.toList();
      print('✅ Archive list updated: ${archives.length} archives');
    });

    archivedList.value = notesService.archivedNotes.toList();
  }

  @override
  void onReady() {
    super.onReady();
    _loadFromServer();
  }

  Future<void> unarchiveNote(String noteId) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      final note = archivedList.firstWhere((n) => n.id == noteId);
      notesService.unarchiveNote(noteId);

      // 🎉 POP-UP DIALOG untuk Unarchive
      _showSuccessDialog(
        title: '📤 Catatan Dikembalikan!',
        message:
            'Catatan "${note.title}" berhasil dikembalikan dari archive ke List Notes.',
        icon: Icons.unarchive,
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
        'Gagal mengembalikan catatan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔧 FIXED: Dialog konfirmasi dengan tombol "Tutup" yang redirect ke archive
  Future<void> deleteArchive(String noteId) async {
    final note = archivedList.firstWhere((n) => n.id == noteId);

    // Konfirmasi dialog dengan peringatan keras
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus PERMANEN arsip "${note.title}"?\n\n⚠️ Data akan hilang selamanya dan tidak dapat dipulihkan!',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog konfirmasi

              try {
                await Future.delayed(const Duration(milliseconds: 200));
                notesService.deleteNote(noteId, isArchived: true);

                // 🎉 POP-UP DIALOG untuk Delete Archive
                _showSuccessDialog(
                  title: '🗑️ Arsip Dihapus Permanen',
                  message:
                      'Arsip "${note.title}" telah dihapus secara permanen dan tidak dapat dipulihkan.',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  actionText: 'Tutup',
                  // 🔧 FIXED: Redirect ke archive page ketika tekan "Tutup"
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.offAllNamed(
                      '/notes/archived',
                    ); // Redirect & clear stack
                  },
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hapus Permanen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void editArchive(String noteId) {
    final note = archivedList.firstWhere((n) => n.id == noteId);
    Get.toNamed('/notes/edit', arguments: note.toMap());
  }

  Future<void> refreshArchives() async {
    try {
      isLoading.value = true;
      await notesService.refreshAll();
      archivedList.value = notesService.archivedNotes.toList();
    } catch (e) {
      print('❌ Error refreshing archived from server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromServer() async {
    try {
      isLoading.value = true;
      await notesService.refreshAll();
      archivedList.value = notesService.archivedNotes.toList();
    } catch (e) {
      print('❌ Error loading archived notes from server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewArchiveDetail(String noteId) {
    final archive = archivedList.firstWhere((n) => n.id == noteId);
    final noteMap = archive.toMap();
    noteMap['isFromArchive'] = true; // 🔧 Tandai dari Archive
    noteMap['isFromDraft'] = false;
    noteMap['isFromScheduled'] = false;
    Get.toNamed(Routes.NOTE_DETAIL, arguments: noteMap);
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
                  color: color.withValues(alpha: 0.1),
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

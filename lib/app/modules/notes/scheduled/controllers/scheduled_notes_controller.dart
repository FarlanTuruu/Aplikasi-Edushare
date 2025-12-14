import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class ScheduledNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final scheduledList = <NoteModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever(notesService.scheduledNotes, (List<NoteModel> scheduled) {
      scheduledList.value = scheduled.toList();
      print('✅ Scheduled list updated: ${scheduled.length} notes');
    });

    scheduledList.value = notesService.scheduledNotes.toList();
    checkAndPublishDueNotes();
  }

  Future<void> publishScheduled(String noteId) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      final note = scheduledList.firstWhere((n) => n.id == noteId);
      notesService.publishScheduled(noteId);

      // 🎉 POP-UP DIALOG untuk Publish Scheduled
      _showSuccessDialog(
        title: '✅ Catatan Dipublikasikan!',
        message:
            'Catatan terjadwal "${note.title}" berhasil dipublikasikan dan sekarang dapat dilihat di List Notes.',
        icon: Icons.publish,
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
        'Gagal mempublikasikan catatan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteScheduled(String noteId) async {
    final note = scheduledList.firstWhere((n) => n.id == noteId);

    // Konfirmasi dialog sebelum hapus
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚠️ Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan terjadwal "${note.title}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog konfirmasi

              try {
                await Future.delayed(const Duration(milliseconds: 200));
                notesService.deleteNote(noteId, isScheduled: true);

                // 🎉 POP-UP DIALOG untuk Delete Archive
                _showSuccessDialog(
                  title: '🗑️ Catatan terjadwal Dihapus Permanen',
                  message:
                      'Catatan terjadwal "${note.title}" telah dihapus secara permanen dan tidak dapat dipulihkan.',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  actionText: 'Tutup',
                  // 🔧 FIXED: Redirect ke archive page ketika tekan "Tutup"
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.offAllNamed(
                      '/notes/scheduled',
                    ); // Redirect & clear stack
                  },
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus catatan: $e',
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

  void editScheduled(String noteId) {
    final note = scheduledList.firstWhere((n) => n.id == noteId);
    Get.toNamed('/notes/edit', arguments: note.toMap());
  }

  void checkAndPublishDueNotes() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueNotes = scheduledList.where((note) {
      final noteDay = DateTime(note.date.year, note.date.month, note.date.day);
      return noteDay.isBefore(today) || noteDay.isAtSameMomentAs(today);
    }).toList();

    for (var note in dueNotes) {
      publishScheduled(note.id);
    }
  }

  Future<void> refreshScheduled() async {
    scheduledList.value = notesService.scheduledNotes.toList();
    checkAndPublishDueNotes();
  }

  void viewScheduledDetail(String noteId) {
    final scheduled = scheduledList.firstWhere((n) => n.id == noteId);
    final noteMap = scheduled.toMap();
    noteMap['isFromArchive'] = false;
    noteMap['isFromDraft'] = false;
    noteMap['isFromScheduled'] = true; // 🔧 Tandai dari Scheduled
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

// File: /lib/app/modules/notes/detail/controllers/detail_notes_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';
import '../../../../routes/app_pages.dart';

class DetailNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  late Rx<NoteModel> note;
  final isLoading = false.obs;

  // 🔧 NEW: Deteksi dari mana catatan berasal
  final isFromArchive = false.obs;
  final isFromDraft = false.obs;
  final isFromScheduled = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 DetailNotesController onInit');

    // Ambil data note dari arguments
    final args = Get.arguments as Map<String, dynamic>;
    note = NoteModel.fromMap(args).obs;

    // 🔧 NEW: Deteksi source dari arguments
    isFromArchive.value = args['isFromArchive'] == true;
    isFromDraft.value = args['isFromDraft'] == true;
    isFromScheduled.value = args['isFromScheduled'] == true;

    print('📝 Note loaded: ${note.value.title}');
    print(
      '📍 Source - Archive: ${isFromArchive.value}, Draft: ${isFromDraft.value}, Scheduled: ${isFromScheduled.value}',
    );
  }

  // Archive/Unarchive/Publish Note (Context-aware)
  Future<void> toggleArchive() async {
    if (isFromArchive.value) {
      // Unarchive (Restore)
      await _unarchiveNote();
    } else if (isFromScheduled.value) {
      // Publish Scheduled
      await _publishScheduled();
    } else {
      // Archive
      await _archiveNote();
    }
  }

  // Publish Scheduled Note
  Future<void> _publishScheduled() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.publish, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Publikasikan Catatan'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mempublikasikan catatan terjadwal "${note.value.title}"?\n\nCatatan akan dipindahkan ke List Notes.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog

              try {
                isLoading.value = true;
                await Future.delayed(const Duration(milliseconds: 300));
                notesService.publishScheduled(note.value.id);

                _showSuccessDialog(
                  title: '✅ Catatan Dipublikasikan',
                  message:
                      'Catatan "${note.value.title}" berhasil dipublikasikan ke List Notes.',
                  icon: Icons.publish,
                  color: Colors.green,
                  actionText: 'Kembali ke List',
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.back(); // Kembali ke scheduled
                  },
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal mempublikasikan: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Publikasikan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _archiveNote() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.archive, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Arsipkan Catatan'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengarsipkan catatan "${note.value.title}"?\n\nCatatan akan dipindahkan ke Archive.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog

              try {
                isLoading.value = true;
                await Future.delayed(const Duration(milliseconds: 300));
                notesService.archiveNote(note.value.id);

                _showSuccessDialog(
                  title: '📦 Catatan Diarsipkan',
                  message:
                      'Catatan "${note.value.title}" berhasil dipindahkan ke Archive.\n\nAnda dapat menemukannya di menu Archive.',
                  icon: Icons.archive,
                  color: Colors.orange,
                  actionText: 'Kembali ke List',
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.back(); // Kembali ke list
                  },
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal mengarsipkan: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Arsipkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unarchiveNote() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.unarchive, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Kembalikan Catatan'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengembalikan catatan "${note.value.title}" dari Archive?\n\nCatatan akan dipindahkan kembali ke List Notes.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog

              try {
                isLoading.value = true;
                await Future.delayed(const Duration(milliseconds: 300));
                notesService.unarchiveNote(note.value.id);

                _showSuccessDialog(
                  title: '📤 Catatan Dikembalikan',
                  message:
                      'Catatan "${note.value.title}" berhasil dikembalikan ke List Notes.',
                  icon: Icons.unarchive,
                  color: Colors.green,
                  actionText: 'Kembali ke Archive',
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.back(); // Kembali ke archive
                  },
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal mengembalikan: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Kembalikan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Edit Note
  void editNote() {
    Get.toNamed(Routes.NOTE_EDIT, arguments: note.value.toMap());
  }

  // Delete Note (Context-aware)
  Future<void> deleteNote() async {
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
          'Apakah Anda yakin ingin menghapus PERMANEN catatan "${note.value.title}"?\n\n⚠️ Data akan hilang selamanya dan tidak dapat dipulihkan!',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Tutup dialog

              try {
                isLoading.value = true;
                await Future.delayed(const Duration(milliseconds: 200));

                // 🔧 NEW: Delete berdasarkan source
                notesService.deleteNote(
                  note.value.id,
                  isArchived: isFromArchive.value,
                  isDraft: isFromDraft.value,
                  isScheduled: isFromScheduled.value,
                );

                _showSuccessDialog(
                  title: '🗑️ Catatan Dihapus',
                  message:
                      'Catatan "${note.value.title}" telah dihapus secara permanen.',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  actionText: 'Tutup',
                  onActionPressed: () {
                    Get.back(); // Tutup dialog
                    Get.back(); // Kembali ke halaman sebelumnya
                  },
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                isLoading.value = false;
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

  // Share Note (placeholder)
  void shareNote() {
    Get.snackbar(
      'Share',
      'Fitur berbagi catatan "${note.value.title}"',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.share, color: Colors.white),
    );
  }

  // Download File (placeholder)
  void downloadFile() {
    if (note.value.fileName == null) {
      Get.snackbar(
        'Info',
        'Tidak ada file yang dilampirkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Download',
      'Mengunduh file: ${note.value.fileName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.download, color: Colors.white),
    );
  }

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

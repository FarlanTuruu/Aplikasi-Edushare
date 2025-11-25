import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class ScheduledNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final scheduledList = <NoteModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // 🔧 FIX: Gunakan ever() listener, bukan bindStream()
    ever(notesService.scheduledNotes, (List<NoteModel> scheduled) {
      scheduledList.value = scheduled.toList();
      print('✅ Scheduled list updated: ${scheduled.length} notes');
    });

    // 🔧 FIX: Set initial value
    scheduledList.value = notesService.scheduledNotes.toList();

    // 🔧 Check untuk auto-publish catatan yang sudah waktunya
    checkAndPublishDueNotes();
  }

  Future<void> publishScheduled(String noteId) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));

      notesService.publishScheduled(noteId);

      Get.snackbar(
        'Success',
        'Catatan terjadwal berhasil dipublikasikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
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
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      notesService.deleteNote(noteId, isScheduled: true);

      Get.snackbar(
        'Success',
        'Catatan terjadwal berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
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
  }

  void editScheduled(String noteId) {
    final note = scheduledList.firstWhere((n) => n.id == noteId);
    Get.toNamed('/notes/create', arguments: note.toMap());
  }

  // 🔧 Check dan auto-publish catatan yang sudah waktunya
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

  // 🔧 Tambahkan refresh method
  Future<void> refreshScheduled() async {
    scheduledList.value = notesService.scheduledNotes.toList();
    checkAndPublishDueNotes(); // Check lagi saat refresh
  }
}

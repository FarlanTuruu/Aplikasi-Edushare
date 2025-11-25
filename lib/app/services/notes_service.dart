import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NotesService extends GetxService {
  final allNotes = <NoteModel>[].obs;
  final draftNotes = <NoteModel>[].obs;
  final scheduledNotes = <NoteModel>[].obs;

  // -------------------------------------------------------------
  // ADD NOTE
  // -------------------------------------------------------------
  void addNote(
    NoteModel note, {
    bool isDraft = false,
    bool isScheduled = false,
  }) {
    if (isDraft) {
      draftNotes.insert(0, note);
      draftNotes.refresh(); // FIX WAJIB
      _showSnack('Catatan berhasil disimpan sebagai draft');
    } else if (isScheduled) {
      scheduledNotes.insert(0, note);
      scheduledNotes.refresh(); // FIX WAJIB
      _showSnack('Catatan berhasil dijadwalkan');
    } else {
      allNotes.insert(0, note);
      allNotes.refresh(); // FIX WAJIB
      _showSnack('Catatan berhasil diunggah');
    }
  }

  // -------------------------------------------------------------
  // PUBLISH DRAFT
  // -------------------------------------------------------------
  void publishDraft(String noteId) {
    final index = draftNotes.indexWhere((e) => e.id == noteId);

    if (index != -1) {
      final note = draftNotes.removeAt(index);
      draftNotes.refresh(); // FIX
      allNotes.insert(0, note);
      allNotes.refresh(); // FIX
    }
  }

  // -------------------------------------------------------------
  // PUBLISH SCHEDULED
  // -------------------------------------------------------------
  void publishScheduled(String noteId) {
    final index = scheduledNotes.indexWhere((e) => e.id == noteId);

    if (index != -1) {
      final note = scheduledNotes.removeAt(index);
      scheduledNotes.refresh(); // FIX
      allNotes.insert(0, note);
      allNotes.refresh(); // FIX
    }
  }

  // -------------------------------------------------------------
  // DELETE NOTE
  // -------------------------------------------------------------
  void deleteNote(
    String noteId, {
    bool isDraft = false,
    bool isScheduled = false,
  }) {
    if (isDraft) {
      draftNotes.removeWhere((e) => e.id == noteId);
      draftNotes.refresh(); // FIX
    } else if (isScheduled) {
      scheduledNotes.removeWhere((e) => e.id == noteId);
      scheduledNotes.refresh(); // FIX
    } else {
      allNotes.removeWhere((e) => e.id == noteId);
      allNotes.refresh(); // FIX
    }
  }

  // -------------------------------------------------------------
  // UPDATE NOTE
  // -------------------------------------------------------------
  void updateNote(
    NoteModel updatedNote, {
    bool isDraft = false,
    bool isScheduled = false,
  }) {
    if (isDraft) {
      final index = draftNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        draftNotes[index] = updatedNote;
        draftNotes.refresh(); // FIX
      }
    } else if (isScheduled) {
      final index = scheduledNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        scheduledNotes[index] = updatedNote;
        scheduledNotes.refresh(); // FIX
      }
    } else {
      final index = allNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        allNotes[index] = updatedNote;
        allNotes.refresh(); // FIX
      }
    }
  }

  // -------------------------------------------------------------
  // CHECK IF DATE IS FUTURE
  // -------------------------------------------------------------
  bool isScheduledDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  // -------------------------------------------------------------
  // SNACKBAR
  // -------------------------------------------------------------
  void _showSnack(String msg) {
    Get.snackbar(
      'Success',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.secondary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

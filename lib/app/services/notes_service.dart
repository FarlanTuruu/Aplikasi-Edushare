import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NotesService extends GetxService {
  final allNotes = <NoteModel>[].obs;
  final draftNotes = <NoteModel>[].obs;
  final scheduledNotes = <NoteModel>[].obs;
  final archivedNotes = <NoteModel>[].obs; // 🆕 TAMBAHAN

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
      draftNotes.refresh();
      _showSnack('Catatan berhasil disimpan sebagai draft');
    } else if (isScheduled) {
      scheduledNotes.insert(0, note);
      scheduledNotes.refresh();
      _showSnack('Catatan berhasil dijadwalkan');
    } else {
      allNotes.insert(0, note);
      allNotes.refresh();
      _showSnack('Catatan berhasil diunggah');
    }
  }

  // -------------------------------------------------------------
  // ARCHIVE NOTE (🆕 NEW METHOD)
  // -------------------------------------------------------------
  void archiveNote(String noteId) {
    final index = allNotes.indexWhere((e) => e.id == noteId);

    if (index != -1) {
      final note = allNotes.removeAt(index);
      allNotes.refresh();
      archivedNotes.insert(0, note);
      archivedNotes.refresh();
      _showSnack('Catatan berhasil diarsipkan');
    }
  }

  // -------------------------------------------------------------
  // UNARCHIVE NOTE (🆕 NEW METHOD)
  // -------------------------------------------------------------
  void unarchiveNote(String noteId) {
    final index = archivedNotes.indexWhere((e) => e.id == noteId);

    if (index != -1) {
      final note = archivedNotes.removeAt(index);
      archivedNotes.refresh();
      allNotes.insert(0, note);
      allNotes.refresh();
      _showSnack('Catatan berhasil dikembalikan');
    }
  }

  // -------------------------------------------------------------
  // PUBLISH DRAFT
  // -------------------------------------------------------------
  void publishDraft(String noteId) {
    final index = draftNotes.indexWhere((e) => e.id == noteId);

    if (index != -1) {
      final note = draftNotes.removeAt(index);
      draftNotes.refresh();
      allNotes.insert(0, note);
      allNotes.refresh();
      _showSnack('Draft berhasil dipublikasikan');
    }
  }

  // -------------------------------------------------------------
  // PUBLISH SCHEDULED
  // -------------------------------------------------------------
  void publishScheduled(String noteId) {
    final index = scheduledNotes.indexWhere((e) => e.id == noteId);

    if (index != -1) {
      final note = scheduledNotes.removeAt(index);
      scheduledNotes.refresh();
      allNotes.insert(0, note);
      allNotes.refresh();
      _showSnack('Catatan terjadwal berhasil dipublikasikan');
    }
  }

  // -------------------------------------------------------------
  // DELETE NOTE
  // -------------------------------------------------------------
  void deleteNote(
    String noteId, {
    bool isDraft = false,
    bool isScheduled = false,
    bool isArchived = false, // 🆕 TAMBAHAN
  }) {
    if (isDraft) {
      draftNotes.removeWhere((e) => e.id == noteId);
      draftNotes.refresh();
    } else if (isScheduled) {
      scheduledNotes.removeWhere((e) => e.id == noteId);
      scheduledNotes.refresh();
    } else if (isArchived) {
      archivedNotes.removeWhere((e) => e.id == noteId);
      archivedNotes.refresh();
    } else {
      allNotes.removeWhere((e) => e.id == noteId);
      allNotes.refresh();
    }
  }

  // -------------------------------------------------------------
  // UPDATE NOTE
  // -------------------------------------------------------------
  void updateNote(
    NoteModel updatedNote, {
    bool isDraft = false,
    bool isScheduled = false,
    bool isArchived = false, // 🆕 TAMBAHAN
  }) {
    if (isDraft) {
      final index = draftNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        draftNotes[index] = updatedNote;
        draftNotes.refresh();
      }
    } else if (isScheduled) {
      final index = scheduledNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        scheduledNotes[index] = updatedNote;
        scheduledNotes.refresh();
      }
    } else if (isArchived) {
      final index = archivedNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        archivedNotes[index] = updatedNote;
        archivedNotes.refresh();
      }
    } else {
      final index = allNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        allNotes[index] = updatedNote;
        allNotes.refresh();
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

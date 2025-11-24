// File: /lib/app/services/notes_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NotesService extends GetxService {
  final allNotes = <NoteModel>[].obs;
  final draftNotes = <NoteModel>[].obs;
  final scheduledNotes = <NoteModel>[].obs;

  void addNote(
    NoteModel note, {
    bool isDraft = false,
    bool isScheduled = false,
  }) {
    if (isDraft) {
      draftNotes.insert(0, note);
      _showSnack('Catatan berhasil disimpan sebagai draft');
    } else if (isScheduled) {
      scheduledNotes.insert(0, note);
      _showSnack('Catatan berhasil dijadwalkan');
    } else {
      allNotes.insert(0, note);
      _showSnack('Catatan berhasil diunggah');
    }
  }

  void publishDraft(String noteId) {
    final index = draftNotes.indexWhere((e) => e.id == noteId);
    if (index != -1) {
      final note = draftNotes.removeAt(index);
      allNotes.insert(0, note);
    }
  }

  void publishScheduled(String noteId) {
    final index = scheduledNotes.indexWhere((e) => e.id == noteId);
    if (index != -1) {
      final note = scheduledNotes.removeAt(index);
      allNotes.insert(0, note);
    }
  }

  void deleteNote(
    String noteId, {
    bool isDraft = false,
    bool isScheduled = false,
  }) {
    if (isDraft) {
      draftNotes.removeWhere((e) => e.id == noteId);
    } else if (isScheduled) {
      scheduledNotes.removeWhere((e) => e.id == noteId);
    } else {
      allNotes.removeWhere((e) => e.id == noteId);
    }
  }

  void updateNote(
    NoteModel updatedNote, {
    bool isDraft = false,
    bool isScheduled = false,
  }) {
    if (isDraft) {
      final index = draftNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) draftNotes[index] = updatedNote;
    } else if (isScheduled) {
      final index = scheduledNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) scheduledNotes[index] = updatedNote;
    } else {
      final index = allNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) allNotes[index] = updatedNote;
    }
  }

  bool isScheduledDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

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

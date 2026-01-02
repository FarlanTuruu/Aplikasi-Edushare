import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';
import '../data/api_client.dart';
import '../data/note_repository.dart';

class NotesService extends GetxService {
  late final ApiClient _apiClient;
  late final NoteRepository _repo;

  final allNotes = <NoteModel>[].obs;
  final draftNotes = <NoteModel>[].obs;
  final scheduledNotes = <NoteModel>[].obs;
  final archivedNotes = <NoteModel>[].obs; // 🆕 TAMBAHAN

  @override
  void onInit() {
    super.onInit();
    _apiClient = ApiClient();
    _repo = NoteRepository(_apiClient);
  }

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
  // API INTEGRATION
  // -------------------------------------------------------------
  Future<NoteModel?> createNoteOnServer(
    NoteModel note, {
    bool isDraft = false,
    bool isScheduled = false,
    String? filePath,
  }) async {
    final status = isDraft ? 'draft' : (isScheduled ? 'scheduled' : 'list');

    final toSend = NoteModel(
      id: note.id,
      title: note.title,
      mataKuliah: note.mataKuliah,
      date: note.date,
      description: note.description,
      fileName: note.fileName,
      status: status,
    );

    final created = (filePath != null && filePath.isNotEmpty)
        ? await _repo.createNoteWithFile(toSend, filePath)
        : await _repo.createNote(toSend);

    if (status == 'draft') {
      draftNotes.insert(0, created);
      draftNotes.refresh();
    } else if (status == 'scheduled') {
      scheduledNotes.insert(0, created);
      scheduledNotes.refresh();
    } else {
      allNotes.insert(0, created);
      allNotes.refresh();
    }
    return created;
  }

  Future<void> loadAllFromServer() async {
    // Fetch each bucket with per-call error isolation so one failing
    // endpoint doesn't blank the entire list on the homepage.
    try {
      final all = await _repo.fetchNotes();
      allNotes.assignAll(all);
    } catch (e) {
      _showSnack('Gagal memuat notes: ${e.toString()}');
    }
    try {
      final drafts = await _repo.fetchDrafts();
      draftNotes.assignAll(drafts);
    } catch (_) {}
    try {
      final scheduled = await _repo.fetchScheduled();
      scheduledNotes.assignAll(scheduled);
    } catch (_) {}
    try {
      final archived = await _repo.fetchArchived();
      archivedNotes.assignAll(archived);
    } catch (_) {}
  }

  Future<void> refreshAll() async {
    await loadAllFromServer();
  }

  // Load only public/published notes for homepage feed visibility
  Future<void> loadPublicFeed() async {
    try {
      final publicNotes = await _repo.fetchNotesPublic();
      allNotes.assignAll(publicNotes);
    } catch (e) {
      _showSnack('Gagal memuat feed: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------
  // SERVER-DRIVEN STATE CHANGES
  // -------------------------------------------------------------
  Future<void> archiveNote(String noteId) async {
    await _repo.archive(noteId);
    final idx = allNotes.indexWhere((e) => e.id == noteId);
    if (idx != -1) {
      final note = allNotes.removeAt(idx);
      allNotes.refresh();
      archivedNotes.insert(0, note.copyWith(status: 'archived'));
      archivedNotes.refresh();
    } else {
      await loadAllFromServer();
    }
  }

  Future<void> unarchiveNote(String noteId) async {
    await _repo.unarchive(noteId);
    final idx = archivedNotes.indexWhere((e) => e.id == noteId);
    if (idx != -1) {
      final note = archivedNotes.removeAt(idx);
      archivedNotes.refresh();
      allNotes.insert(0, note.copyWith(status: 'list'));
      allNotes.refresh();
    } else {
      await loadAllFromServer();
    }
  }

  Future<void> publishDraft(String noteId) async {
    await _repo.publish(noteId);
    final idx = draftNotes.indexWhere((e) => e.id == noteId);
    if (idx != -1) {
      final note = draftNotes.removeAt(idx);
      draftNotes.refresh();
      allNotes.insert(0, note.copyWith(status: 'list'));
      allNotes.refresh();
    } else {
      await loadAllFromServer();
    }
  }

  Future<void> publishScheduled(String noteId) async {
    await _repo.publish(noteId);
    final idx = scheduledNotes.indexWhere((e) => e.id == noteId);
    if (idx != -1) {
      final note = scheduledNotes.removeAt(idx);
      scheduledNotes.refresh();
      allNotes.insert(0, note.copyWith(status: 'list'));
      allNotes.refresh();
    } else {
      await loadAllFromServer();
    }
  }

  Future<void> deleteNote(
    String noteId, {
    bool isDraft = false,
    bool isScheduled = false,
    bool isArchived = false,
  }) async {
    await _repo.deleteNote(noteId);
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

  Future<void> updateNote(
    NoteModel updatedNote, {
    bool isDraft = false,
    bool isScheduled = false,
    bool isArchived = false,
  }) async {
    final saved = await _repo.updateNote(updatedNote);
    NoteModel apply(NoteModel _) => saved;

    if (isDraft) {
      final index = draftNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        draftNotes[index] = apply(draftNotes[index]);
        draftNotes.refresh();
      }
    } else if (isScheduled) {
      final index = scheduledNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        scheduledNotes[index] = apply(scheduledNotes[index]);
        scheduledNotes.refresh();
      }
    } else if (isArchived) {
      final index = archivedNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        archivedNotes[index] = apply(archivedNotes[index]);
        archivedNotes.refresh();
      }
    } else {
      final index = allNotes.indexWhere((e) => e.id == updatedNote.id);
      if (index != -1) {
        allNotes[index] = apply(allNotes[index]);
        allNotes.refresh();
      }
    }
  }

  // -------------------------------------------------------------
  // ARCHIVE NOTE (🆕 NEW METHOD)
  // -------------------------------------------------------------
  // Removed legacy local-only implementation (now handled via REST above)

  // -------------------------------------------------------------
  // UNARCHIVE NOTE (🆕 NEW METHOD)
  // -------------------------------------------------------------
  // Removed legacy local-only implementation (now handled via REST above)

  // -------------------------------------------------------------
  // PUBLISH DRAFT
  // -------------------------------------------------------------
  // Removed legacy local-only implementation (now handled via REST above)

  // -------------------------------------------------------------
  // PUBLISH SCHEDULED
  // -------------------------------------------------------------
  // Removed legacy local-only implementation (now handled via REST above)

  // -------------------------------------------------------------
  // DELETE NOTE
  // -------------------------------------------------------------
  // Removed legacy local-only implementation (now handled via REST above)

  // -------------------------------------------------------------
  // UPDATE NOTE
  // -------------------------------------------------------------
  // Removed legacy local-only implementation (now handled via REST above)

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

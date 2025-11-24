// File 2: FIXED list_notes_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';
import '../../../../routes/app_pages.dart';

class ListNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final notesList = <NoteModel>[].obs;
  final filteredNotesList = <NoteModel>[].obs;
  final isLoading = false.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // 🔧 Bind langsung dengan service
    notesList.bindStream(notesService.allNotes.stream);

    // Update filtered setiap notesList berubah
    ever<List<NoteModel>>(notesList, (_) {
      filteredNotesList.value = notesList.toList();
    });

    // 🔧 HAPUS BAGIAN ARGUMENTS - sudah tidak perlu
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void searchNotes(String query) {
    if (query.trim().isEmpty) {
      filteredNotesList.value = notesList.toList();
      return;
    }

    final q = query.toLowerCase();
    filteredNotesList.value = notesList.where((note) {
      return note.title.toLowerCase().contains(q) ||
          note.mataKuliah.toLowerCase().contains(q) ||
          note.description.toLowerCase().contains(q);
    }).toList();
  }

  void showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Terbaru'),
              onTap: () {
                sortByNewest();
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Terlama'),
              onTap: () {
                sortByOldest();
                Get.back();
              },
            ),
            ListTile(
              title: const Text('A-Z'),
              onTap: () {
                sortByTitle();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void sortByNewest() {
    filteredNotesList.sort((a, b) => b.date.compareTo(a.date));
    filteredNotesList.refresh();
  }

  void sortByOldest() {
    filteredNotesList.sort((a, b) => a.date.compareTo(b.date));
    filteredNotesList.refresh();
  }

  void sortByTitle() {
    filteredNotesList.sort((a, b) => a.title.compareTo(b.title));
    filteredNotesList.refresh();
  }

  Future<void> archiveNote(String noteId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      notesService.deleteNote(noteId);

      Get.snackbar(
        'Success',
        'Catatan berhasil diarsipkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengarsipkan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  void editNote(String noteId) {
    final note = notesList.firstWhere((n) => n.id == noteId);
    Get.toNamed(Routes.NOTE_CREATE, arguments: note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      notesService.deleteNote(noteId);

      Get.snackbar(
        'Success',
        'Catatan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> refreshNotes() async {
    filteredNotesList.value = notesList.toList();
  }
}

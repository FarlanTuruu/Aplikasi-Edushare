import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';
import '../../../../routes/app_pages.dart';

class ListNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final filteredNotesList = <NoteModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  // 🔧 FIX: Gunakan TextEditingController yang lebih aman
  TextEditingController? _searchController;
  TextEditingController get searchController {
    _searchController ??= TextEditingController();
    return _searchController!;
  }

  Worker? _notesWorker;

  @override
  void onInit() {
    super.onInit();
    print('🟢 ListNotesController onInit');

    // Initialize controller
    _searchController = TextEditingController();

    // Setup worker dengan onError handler
    _notesWorker = ever(
      notesService.allNotes,
      _updateNotesList,
      onError: (error) {
        print('❌ Worker error: $error');
      },
    );

    // Load initial data
    _updateNotesList(notesService.allNotes);
  }

  @override
  void onReady() {
    super.onReady();
    print('🟢 ListNotesController onReady');
    _loadFromServer();
  }

  @override
  void onClose() {
    print('🔴 ListNotesController onClose - START');

    // 1. Dispose worker terlebih dahulu
    try {
      _notesWorker?.dispose();
      _notesWorker = null;
      print('✅ Worker disposed');
    } catch (e) {
      print('⚠️ Error disposing worker: $e');
    }

    // 2. Dispose search controller dengan aman
    try {
      if (_searchController != null) {
        _searchController!.clear();
        _searchController!.dispose();
        _searchController = null;
        print('✅ SearchController disposed');
      }
    } catch (e) {
      print('⚠️ Error disposing searchController: $e');
    }

    print('🔴 ListNotesController onClose - END');
    super.onClose();
  }

  void _updateNotesList(List<NoteModel> notes) {
    try {
      if (searchQuery.value.trim().isEmpty) {
        filteredNotesList.value = notes.toList();
      } else {
        searchNotes(searchQuery.value);
      }
      print('✅ List updated: ${notes.length} notes');
    } catch (e) {
      print('❌ Error updating notes list: $e');
    }
  }

  void searchNotes(String query) {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      filteredNotesList.value = notesService.allNotes.toList();
      return;
    }

    final q = query.toLowerCase();
    filteredNotesList.value = notesService.allNotes.where((note) {
      return note.title.toLowerCase().contains(q) ||
          note.mataKuliah.toLowerCase().contains(q) ||
          note.description.toLowerCase().contains(q);
    }).toList();
  }

  void clearSearch() {
    if (_searchController != null && _searchController!.text.isNotEmpty) {
      _searchController!.clear();
    }
    searchQuery.value = '';
    filteredNotesList.value = notesService.allNotes.toList();
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

  void viewNoteDetail(String noteId) {
    final note = notesService.allNotes.firstWhere((n) => n.id == noteId);
    final noteMap = note.toMap();
    noteMap['isFromArchive'] = false; // 🔧 Tandai dari List
    noteMap['isFromDraft'] = false;
    noteMap['isFromScheduled'] = false;
    Get.toNamed(Routes.NOTE_DETAIL, arguments: noteMap);
  }

  Future<void> archiveNote(String noteId) async {
    final note = notesService.allNotes.firstWhere((n) => n.id == noteId);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      notesService.archiveNote(noteId);

      _showSuccessDialog(
        title: '📦 Catatan Diarsipkan',
        message:
            'Catatan "${note.title}" berhasil dipindahkan ke Archive.\n\nAnda dapat menemukannya di menu Archive.',
        icon: Icons.archive,
        color: Colors.orange,
        actionText: 'Lihat Archive',
        onActionPressed: () {
          Get.back();
          Get.toNamed('/notes/archived');
        },
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
    final note = notesService.allNotes.firstWhere((n) => n.id == noteId);
    Get.toNamed(Routes.NOTE_EDIT, arguments: note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    final note = notesList.firstWhere((n) => n.id == noteId);

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
          'Apakah Anda yakin ingin menghapus PERMANEN catatan "${note.title}"?\n\n⚠️ Data akan hilang selamanya dan tidak dapat dipulihkan!',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              try {
                await Future.delayed(const Duration(milliseconds: 200));
                notesService.deleteNote(noteId, isArchived: false);

                _showSuccessDialog(
                  title: '🗑️ Catatan Dihapus Permanen',
                  message:
                      'Catatan "${note.title}" telah dihapus secara permanen dan tidak dapat dipulihkan.',
                  icon: Icons.delete_forever,
                  color: Colors.red,
                  actionText: 'Tutup',
                  onActionPressed: () {
                    Get.until((route) => route.isFirst || !Get.isDialogOpen!);
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
            child: const Text(
              'Hapus Permanen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refreshNotes() async {
    try {
      isLoading.value = true;
      await notesService.refreshAll();
      filteredNotesList.value = notesService.allNotes.toList();
      print('🔄 Notes refreshed: ${filteredNotesList.length}');
    } catch (e) {
      print('❌ Error refreshing notes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromServer() async {
    try {
      isLoading.value = true;
      await notesService.refreshAll();
      _updateNotesList(notesService.allNotes);
    } catch (e) {
      print('❌ Error loading notes from server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<NoteModel> get notesList => notesService.allNotes;

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

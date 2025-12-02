// File: /lib/app/modules/notes/edit/controllers/edit_notes_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class EditNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final selectedFileName = ''.obs;
  final isLoading = false.obs;

  final mataKuliahController = TextEditingController();
  final judulController = TextEditingController();
  final tanggalController = TextEditingController();
  final deskripsiController = TextEditingController();

  PlatformFile? selectedFile;
  late String noteId;
  late NoteModel originalNote;

  @override
  void onInit() {
    super.onInit();
    _loadNoteData();
  }

  @override
  void onClose() {
    mataKuliahController.dispose();
    judulController.dispose();
    tanggalController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  // 🔥 LOAD NOTE DATA - Dipanggil saat controller init
  void _loadNoteData() {
    try {
      final args = Get.arguments;

      if (args == null) {
        Get.snackbar(
          'Error',
          'Data catatan tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
        return;
      }

      // Parse note data dari arguments
      if (args is Map<String, dynamic>) {
        originalNote = NoteModel.fromMap(args);
      } else if (args is NoteModel) {
        originalNote = args;
      } else {
        throw Exception('Invalid argument type');
      }

      noteId = originalNote.id;

      // Isi form dengan data existing
      mataKuliahController.text = originalNote.mataKuliah;
      judulController.text = originalNote.title;
      deskripsiController.text = originalNote.description;
      tanggalController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(originalNote.date);

      if (originalNote.fileName != null && originalNote.fileName!.isNotEmpty) {
        selectedFileName.value = originalNote.fileName!;
      }

      print('✅ Note loaded for editing: ${originalNote.title}');
    } catch (e) {
      print('❌ Error loading note: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data catatan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        selectedFile = result.files.first;
        selectedFileName.value = selectedFile!.name;

        Get.snackbar(
          'Success',
          'File selected: ${selectedFile!.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectDate() async {
    final ctx = Get.context;
    if (ctx == null) return;

    final pickedDate = await showDatePicker(
      context: ctx,
      initialDate: originalNote.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B2C91),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      tanggalController.text = formattedDate;
      update();
    }
  }

  bool validateForm() {
    if (mataKuliahController.text.trim().isEmpty) {
      _validationError('Mata Kuliah tidak boleh kosong');
      return false;
    }
    if (judulController.text.trim().isEmpty) {
      _validationError('Judul Catatan tidak boleh kosong');
      return false;
    }
    if (tanggalController.text.trim().isEmpty) {
      _validationError('Tanggal tidak boleh kosong');
      return false;
    }
    if (deskripsiController.text.trim().isEmpty) {
      _validationError('Deskripsi tidak boleh kosong');
      return false;
    }
    return true;
  }

  void _validationError(String msg) {
    Get.snackbar(
      'Validation Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  NoteModel _buildUpdatedNote() {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd/MM/yyyy').parseStrict(tanggalController.text);
    } catch (_) {
      parsedDate = originalNote.date;
    }

    return NoteModel(
      id: noteId, // Gunakan ID yang sama
      title: judulController.text.trim(),
      mataKuliah: mataKuliahController.text.trim(),
      date: parsedDate,
      description: deskripsiController.text.trim(),
      fileName: selectedFileName.value.isEmpty ? null : selectedFileName.value,
    );
  }

  // 🎯 UPDATE NOTE
  Future<void> updateNote() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedNote = _buildUpdatedNote();

      // Update note di service
      notesService.updateNote(updatedNote);

      // Show success dialog
      _showSuccessDialog(
        title: '✅ Catatan Diperbarui!',
        message:
            'Catatan "${updatedNote.title}" berhasil diperbarui!\n\nPerubahan telah disimpan.',
        icon: Icons.check_circle,
        color: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui catatan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
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
                  color: color.withOpacity(0.1),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        Get.back(); // Kembali ke list
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Tutup', style: TextStyle(color: color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        Get.offAllNamed(
                          '/notes/list',
                        ); // Kembali ke list dan hapus history
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lihat Catatan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void cancelEdit() {
    // Check apakah ada perubahan
    final hasChanges =
        mataKuliahController.text != originalNote.mataKuliah ||
        judulController.text != originalNote.title ||
        deskripsiController.text != originalNote.description ||
        tanggalController.text !=
            DateFormat('dd/MM/yyyy').format(originalNote.date);

    if (hasChanges) {
      Get.dialog(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan perubahan?\n\nSemua perubahan tidak akan disimpan.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Tidak')),
            TextButton(
              onPressed: () {
                Get.back(); // Tutup dialog
                Get.back(); // Kembali ke list
              },
              child: const Text('Ya', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Get.back(); // Langsung kembali jika tidak ada perubahan
    }
  }
}

// File 1: FIXED create_notes_controller.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../services/notes_service.dart';
import '../../../../models/note_model.dart';

class CreateNotesController extends GetxController {
  final notesService = Get.find<NotesService>();

  final selectedFileName = ''.obs;
  final isLoading = false.obs;

  final mataKuliahController = TextEditingController();
  final judulController = TextEditingController();
  final tanggalController = TextEditingController();
  final deskripsiController = TextEditingController();

  PlatformFile? selectedFile;

  @override
  void onClose() {
    mataKuliahController.dispose();
    judulController.dispose();
    tanggalController.dispose();
    deskripsiController.dispose();
    super.onClose();
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
      initialDate: DateTime.now(),
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
      print('✅ Tanggal dipilih: $formattedDate');
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

  NoteModel _buildNote() {
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd/MM/yyyy').parseStrict(tanggalController.text);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: judulController.text.trim(),
      mataKuliah: mataKuliahController.text.trim(),
      date: parsedDate,
      description: deskripsiController.text.trim(),
      fileName: selectedFileName.value.isEmpty ? null : selectedFileName.value,
    );
  }

  // 🔧 FIX: Langsung tambahkan ke service, jangan kirim via arguments
  Future<void> uploadNote() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      final note = _buildNote();
      final isScheduled = notesService.isScheduledDate(note.date);

      // 🔧 TAMBAHKAN LANGSUNG KE SERVICE
      notesService.addNote(note, isScheduled: isScheduled);

      if (isScheduled) {
        Get.snackbar(
          'Success',
          'Catatan dijadwalkan untuk ${note.fullDate}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Success',
          'Catatan berhasil diunggah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // 🔧 CLEAR FORM tapi JANGAN tutup halaman
      clearForm();

      // 🔧 OPTIONAL: Redirect ke list setelah 1 detik
      // await Future.delayed(const Duration(seconds: 1));
      // Get.toNamed('/notes/list');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunggah catatan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔧 FIX: Langsung tambahkan ke service untuk draft
  Future<void> saveAsDraft() async {
    if (mataKuliahController.text.trim().isEmpty &&
        judulController.text.trim().isEmpty) {
      _validationError('Minimal isi Mata Kuliah atau Judul Catatan');
      return;
    }

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      final note = _buildNote();

      // 🔧 TAMBAHKAN LANGSUNG KE SERVICE
      notesService.addNote(note, isDraft: true);

      Get.snackbar(
        'Success',
        'Catatan berhasil disimpan sebagai draft',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 🔧 CLEAR FORM tapi JANGAN tutup halaman
      clearForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan draft: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void cancelNote() {
    if (mataKuliahController.text.isNotEmpty ||
        judulController.text.isNotEmpty ||
        tanggalController.text.isNotEmpty ||
        deskripsiController.text.isNotEmpty ||
        selectedFileName.value.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan? Data yang telah diisi akan hilang.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Tidak')),
            TextButton(
              onPressed: () {
                Get.back(); // Tutup dialog
                clearForm();
              },
              child: const Text('Ya', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Get.back(); // Kembali ke halaman sebelumnya jika tidak ada data
    }
  }

  void clearForm() {
    mataKuliahController.clear();
    judulController.clear();
    tanggalController.clear();
    deskripsiController.clear();
    selectedFileName.value = '';
    selectedFile = null;
  }
}

// File: /lib/app/modules/notes/create/controllers/create_notes_controller.dart

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

  // Upload Note (Create New)
  Future<void> uploadNote() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      final note = _buildNote();
      final isScheduled = notesService.isScheduledDate(note.date);

      notesService.addNote(note, isScheduled: isScheduled);

      _showSuccessDialog(
        title: isScheduled ? '📅 Catatan Dijadwalkan!' : '✅ Catatan Diunggah!',
        message: isScheduled
            ? 'Catatan "${note.title}" berhasil dijadwalkan untuk tanggal ${note.fullDate}.\n\nCatatan akan muncul di Scheduled Notes.'
            : 'Catatan "${note.title}" berhasil diunggah!\n\nCatatan sudah tersimpan di List Notes.',
        icon: isScheduled ? Icons.schedule : Icons.check_circle,
        color: isScheduled ? const Color(0xFF6B2C91) : Colors.green,
        destination: isScheduled ? 'Scheduled Notes' : 'List Notes',
      );

      clearForm();
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

  // Save as Draft
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
      notesService.addNote(note, isDraft: true);

      _showSuccessDialog(
        title: '💾 Draft Tersimpan!',
        message:
            'Catatan "${note.title}" berhasil disimpan sebagai draft.\n\nAnda dapat melanjutkan pengeditan nanti dari List Notes.',
        icon: Icons.save_outlined,
        color: Colors.blue,
        destination: 'List Notes (Draft)',
      );

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

  void _showSuccessDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String destination,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      destination,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
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
                        Get.back();
                        Get.toNamed('/notes/list');
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
                Get.back();
                clearForm();
                Get.back();
              },
              child: const Text('Ya', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      Get.back();
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

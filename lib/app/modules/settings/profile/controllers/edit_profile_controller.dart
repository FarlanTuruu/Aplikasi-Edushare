// lib/app/modules/settings/profile/controllers/edit_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import './profile_settings_controller.dart';

class EditProfileController extends GetxController {
  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Observable variables
  final profileImageUrl = 'https://i.pravatar.cc/150?img=47'.obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Reference ke ProfileSettingsController
  final ProfileSettingsController profileController =
      Get.find<ProfileSettingsController>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    loadUserData();
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      // Load data dari ProfileSettingsController
      nameController.text = profileController.userName.value;
      emailController.text = profileController.userEmail.value;
      phoneController.text = profileController.userPhone.value;
      profileImageUrl.value = profileController.profileImageUrl.value;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CHANGE PROFILE PICTURE
  // ============================================================
  void changeProfilePicture() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Foto Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF5B2C91)),
              title: const Text('Ambil Foto'),
              onTap: () => _pickImageFromCamera(),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF5B2C91),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => _pickImageFromGallery(),
            ),
            if (profileImageUrl.value != 'https://i.pravatar.cc/150?img=47')
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _removeProfilePicture(),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PICK IMAGE FROM CAMERA
  // ============================================================
  Future<void> _pickImageFromCamera() async {
    try {
      Get.back();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImageUrl.value = image.path;
        Get.snackbar(
          'Sukses',
          'Foto profile berhasil diubah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ============================================================
  // PICK IMAGE FROM GALLERY
  // ============================================================
  Future<void> _pickImageFromGallery() async {
    try {
      Get.back();
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        profileImageUrl.value = image.path;
        Get.snackbar(
          'Sukses',
          'Foto profile berhasil diubah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ============================================================
  // REMOVE PROFILE PICTURE
  // ============================================================
  void _removeProfilePicture() {
    Get.back();
    profileImageUrl.value = 'https://i.pravatar.cc/150?img=47';
    Get.snackbar(
      'Sukses',
      'Foto profile berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ============================================================
  // VALIDATE INPUT
  // ============================================================
  bool _validateInput() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Nama tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    if (phoneController.text.trim().isNotEmpty) {
      if (!GetUtils.isPhoneNumber(phoneController.text.trim())) {
        Get.snackbar(
          'Error',
          'Format nomor telepon tidak valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================
  Future<void> saveProfile() async {
    if (!_validateInput()) return;

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Update ProfileSettingsController dengan data baru
      profileController.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        imageUrl: profileImageUrl.value,
      );

      isLoading.value = false;

      // Tampilkan dialog sukses
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B2C91),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Berhasil!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Profile Anda telah berhasil diperbarui',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.until(
                        (route) => Get.currentRoute == '/settings/profile',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B2C91),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
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
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal menyimpan profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}

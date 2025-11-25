// lib/app/modules/settings/profile/controllers/edit_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Observable variables
  final profileImageUrl = 'https://i.pravatar.cc/150?img=47'.obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    // Load user data
    loadUserData();
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;

      // TODO: Load data dari local storage atau API
      // Simulasi loading
      await Future.delayed(const Duration(milliseconds: 500));

      // Contoh data dummy
      nameController.text = 'Nanda Adela';
      emailController.text = 'Nanda@gmail.com';
      phoneController.text = '081234567890';

      // TODO: Implementasi actual
      // final userData = await StorageService.getUserData();
      // nameController.text = userData.name ?? '';
      // emailController.text = userData.email ?? '';
      // phoneController.text = userData.phone ?? '';
      // profileImageUrl.value = userData.profileImage ?? profileImageUrl.value;
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
      Get.back(); // Close bottom sheet

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // TODO: Upload ke server dan dapatkan URL
        // final uploadedUrl = await uploadImageToServer(image.path);
        // profileImageUrl.value = uploadedUrl;

        // Sementara gunakan local path
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
      Get.back(); // Close bottom sheet

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // TODO: Upload ke server dan dapatkan URL
        // final uploadedUrl = await uploadImageToServer(image.path);
        // profileImageUrl.value = uploadedUrl;

        // Sementara gunakan local path
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
    Get.back(); // Close bottom sheet

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

    // Validasi format email
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

    // Validasi nomor telepon (opsional)
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
    // Validasi input
    if (!_validateInput()) return;

    try {
      isLoading.value = true;

      // TODO: Save to API or local storage
      // Simulasi API call
      await Future.delayed(const Duration(seconds: 1));

      // Contoh implementasi:
      // final response = await ApiService.updateProfile({
      //   'name': nameController.text.trim(),
      //   'email': emailController.text.trim(),
      //   'phone': phoneController.text.trim(),
      //   'profile_image': profileImageUrl.value,
      // });

      // if (response.success) {
      //   await StorageService.saveUserData(response.data);
      // }

      Get.snackbar(
        'Sukses',
        'Profile berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Kembali ke halaman profile
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
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

// lib/app/modules/settings/profile/controllers/edit_profile_controller.dart

import 'package:appedushare/app/data/api_client.dart';
import 'package:appedushare/app/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import './profile_settings_controller.dart';
import 'package:flutter/painting.dart';

class EditProfileController extends GetxController {
  // Text Controllers
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Observable variables
  final profileImageUrl = 'https://i.pravatar.cc/150?img=47'.obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Reference ke ProfileSettingsController (ensure registered at runtime)
  late final ProfileSettingsController profileController;

  late final ProfileRepository _repo;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    // Ensure ProfileSettingsController is available
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.put(ProfileSettingsController(), permanent: true);
    }
    profileController = Get.find<ProfileSettingsController>();
    // Ensure repository is available
    final api = Get.isRegistered<ApiClient>()
        ? Get.find<ApiClient>()
        : Get.put(ApiClient(), permanent: true);
    _repo = Get.isRegistered<ProfileRepository>()
        ? Get.find<ProfileRepository>()
        : Get.put(ProfileRepository(api), permanent: true);
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
    try {
      isLoading.value = true;
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final imagePath = profileImageUrl.value;

      // Compare with original values to determine changes
      final originalName = profileController.userName.value;
      final originalEmail = profileController.userEmail.value;
      final originalPhone = profileController.userPhone.value;
      final originalImage = profileController.profileImageUrl.value;

      final changedName = name != originalName;
      final changedEmail = email != originalEmail;
      final changedPhone = phone != originalPhone;
      final imageChanged = imagePath != originalImage;

      if (!changedName && !changedEmail && !changedPhone && !imageChanged) {
        isLoading.value = false;
        Get.snackbar(
          'Info',
          'Tidak ada perubahan untuk disimpan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Validate only the fields that changed
      if (changedName && name.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Nama tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      if (changedEmail) {
        if (email.isEmpty) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Email tidak boleh kosong',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
        if (!GetUtils.isEmail(email)) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Format email tidak valid',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
      }
      if (changedPhone && phone.isNotEmpty) {
        if (!GetUtils.isPhoneNumber(phone)) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Format nomor telepon tidak valid',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
      }

      final fields = <String, String>{};
      if (changedName) fields['name'] = name;
      if (changedEmail) fields['email'] = email;
      if (changedPhone) fields['phone'] = phone;

      // 1. Proses Upload / Update ke API
      final isLocalFile =
          !(imagePath.startsWith('http://') ||
              imagePath.startsWith('https://'));

      if (imageChanged && isLocalFile) {
        // Send multipart only if image changed and it's a local file
        await _repo.updateProfileWithImage(
          filePath: imagePath,
          fields: fields.isEmpty ? null : fields,
          endpoint: 'profile/update',
          fileFieldName: 'image',
          usePut: false,
        );
      } else {
        // JSON update: include only changed fields
        final jsonPayload = Map<String, String>.from(fields);
        if (imageChanged && !isLocalFile) {
          jsonPayload['image'] = imagePath;
        }
        if (jsonPayload.isNotEmpty) {
          await _repo.updateProfile(jsonPayload);
        }
      }

      // 2. FORCE CLEAR CACHE IMAGE FLUTTER (PENTING!)
      // Ini menghapus semua cache gambar di memori aplikasi saat ini
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // 3. BERI JEDA WAKTU (DELAY) SEDIKIT
      // Server butuh waktu untuk menimpa file lama. 500ms - 1 detik biasanya cukup.
      await Future.delayed(const Duration(milliseconds: 1000));

      // 4. Reload data di Controller Profile Settings
      // Ini akan mengambil URL baru dengan timestamp baru
      await profileController.loadUserData();

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
                      // Tutup dialog
                      if (Get.isDialogOpen ?? false) Get.back();

                      // Kembali ke halaman Profile Settings
                      // Menggunakan Get.back() biasa lebih aman daripada loop route
                      Get.back();
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

// lib/app/modules/settings/profile/bindings/edit_profile_binding.dart

import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_settings_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan ProfileSettingsController sudah ada atau buat jika belum
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.lazyPut<ProfileSettingsController>(() => ProfileSettingsController());
    }

    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}

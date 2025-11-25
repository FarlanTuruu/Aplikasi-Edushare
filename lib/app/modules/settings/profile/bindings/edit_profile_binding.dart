// lib/app/modules/settings/profile/bindings/edit_profile_binding.dart

import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}

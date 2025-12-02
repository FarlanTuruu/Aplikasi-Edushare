// File: /lib/app/modules/notes/edit/bindings/edit_notes_binding.dart

import 'package:get/get.dart';
import '../controllers/edit_notes_controller.dart';

class EditNotesBinding extends Bindings {
  @override
  void dependencies() {
    // Instantiate EditNotesController saat halaman dibuka
    Get.lazyPut<EditNotesController>(() => EditNotesController());
  }
}

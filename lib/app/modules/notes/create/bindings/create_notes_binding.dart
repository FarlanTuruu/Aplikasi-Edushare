// File 1: /lib/app/modules/notes/create/bindings/create_notes_binding.dart
// ============================================================

import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../controllers/create_notes_controller.dart';

class CreateNotesBinding extends Bindings {
  @override
  void dependencies() {
    // 🔧 Cek apakah NotesService sudah ada, jika tidak buat baru
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }

    // Inject controller
    Get.lazyPut<CreateNotesController>(() => CreateNotesController());
  }
}

// File 3: /lib/app/modules/notes/draft/bindings/draft_notes_binding.dart
// ============================================================

import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../controllers/draft_notes_controller.dart';

class DraftNotesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }

    Get.lazyPut<DraftNotesController>(() => DraftNotesController());
  }
}

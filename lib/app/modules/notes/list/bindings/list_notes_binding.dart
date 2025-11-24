// File 2: /lib/app/modules/notes/list/bindings/list_notes_binding.dart
// ============================================================

import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../controllers/list_notes_controller.dart';

class ListNotesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }

    Get.lazyPut<ListNotesController>(() => ListNotesController());
  }
}

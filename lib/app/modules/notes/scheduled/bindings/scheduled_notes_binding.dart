// File 4: /lib/app/modules/notes/scheduled/bindings/scheduled_notes_binding.dart
// ============================================================

import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../controllers/scheduled_notes_controller.dart';

class ScheduledNotesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }

    Get.lazyPut<ScheduledNotesController>(() => ScheduledNotesController());
  }
}

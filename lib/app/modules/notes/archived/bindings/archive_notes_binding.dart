import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../controllers/archive_notes_controller.dart';

// ==================== BINDING ====================
// File: archive_notes_binding.dart
class ArchiveNotesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }
    Get.lazyPut<ArchiveNotesController>(() => ArchiveNotesController());
  }
}

import 'package:get/get.dart';

import '../controllers/archive_notes_controller.dart';

// ==================== BINDING ====================
// File: archive_notes_binding.dart
class ArchiveNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchiveNotesController>(() => ArchiveNotesController());
  }
}

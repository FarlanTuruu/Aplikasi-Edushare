import 'package:get/get.dart';
import '../../../../services/notes_service.dart';
import '../controllers/list_notes_controller.dart';

class ListNotesBinding extends Bindings {
  @override
  void dependencies() {
    // NotesService tetap permanent (shared across app)
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }

    // 🔧 FIX: Delete controller setiap kali keluar dari page
    Get.delete<ListNotesController>(force: true);

    // 🔧 FIX: Create fresh controller setiap kali masuk page
    Get.put(
      ListNotesController(),
      permanent: false, // PENTING: jangan permanent!
    );
  }
}

import 'package:get/get.dart';

import '../controllers/draft_notes_controller.dart';

class DraftNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DraftNotesController>(() => DraftNotesController());
  }
}

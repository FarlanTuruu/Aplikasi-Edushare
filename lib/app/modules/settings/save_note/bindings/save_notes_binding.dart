import 'package:get/get.dart';

import '../controllers/save_notes_controller.dart';

class SaveNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaveNotesController>(() => SaveNotesController());
  }
}

import 'package:get/get.dart';

import '../controllers/create_notes_controller.dart';

class CreateNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNotesController>(() => CreateNotesController());
  }
}

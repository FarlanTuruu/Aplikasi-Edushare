import 'package:get/get.dart';

import '../controllers/list_notes_controller.dart';

class ListNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListNotesController>(() => ListNotesController());
  }
}

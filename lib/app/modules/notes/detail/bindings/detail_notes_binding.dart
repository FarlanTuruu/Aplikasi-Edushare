// File: /lib/app/modules/notes/detail/bindings/detail_notes_binding.dart

import 'package:get/get.dart';
import '../controllers/detail_notes_controller.dart';

class DetailNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailNotesController>(() => DetailNotesController());
  }
}

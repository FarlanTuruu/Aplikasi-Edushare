import 'package:get/get.dart';

import '../controllers/scheduled_notes_controller.dart';

class ScheduledNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduledNotesController>(() => ScheduledNotesController());
  }
}

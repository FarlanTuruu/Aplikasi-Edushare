import 'package:get/get.dart';

import '../controllers/edit_collaboration_controller.dart';

class EditCollaborationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditCollaborationController>(
      () => EditCollaborationController(),
    );
  }
}

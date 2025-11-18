import 'package:get/get.dart';

import '../controllers/create_collaboration_controller.dart';

class CreateCollaborationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateCollaborationController>(
      () => CreateCollaborationController(),
    );
  }
}

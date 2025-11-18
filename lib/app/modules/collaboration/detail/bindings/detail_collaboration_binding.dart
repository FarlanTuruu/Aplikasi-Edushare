import 'package:get/get.dart';

import '../controllers/detail_collaboration_controller.dart';

class DetailCollaborationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailCollaborationController>(
      () => DetailCollaborationController(),
    );
  }
}

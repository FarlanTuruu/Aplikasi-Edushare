import 'package:appedushare/app/modules/collaboration/list/controllers/list_collaboration_controller.dart';
import 'package:get/get.dart';

class ListCollaborationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListCollaborationController>(
      () => ListCollaborationController(),
    );
  }
}

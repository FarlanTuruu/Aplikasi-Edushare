import 'package:get/get.dart';

import '../controllers/rooms_controller.dart';

class RoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomsController>(() => RoomsController());
  }
}

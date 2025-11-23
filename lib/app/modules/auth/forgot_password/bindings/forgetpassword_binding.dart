import 'package:get/get.dart';

import '../controllers/forgetpassword_controller.dart';

class Forgetbinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgetPasswordController>(() => ForgetPasswordController());
  }
}

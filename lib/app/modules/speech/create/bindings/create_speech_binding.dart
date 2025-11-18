import 'package:get/get.dart';

import '../controllers/create_speech_controller.dart';

class CreateSpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateSpeechController>(() => CreateSpeechController());
  }
}

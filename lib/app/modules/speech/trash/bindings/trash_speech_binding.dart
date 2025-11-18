import 'package:get/get.dart';

import '../controllers/trash_speech_controller.dart';

class TrashSpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrashSpeechController>(() => TrashSpeechController());
  }
}

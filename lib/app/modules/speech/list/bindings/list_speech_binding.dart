import 'package:get/get.dart';

import '../controllers/list_speech_controller.dart';

class ListSpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ListSpeechController>(() => ListSpeechController());
  }
}

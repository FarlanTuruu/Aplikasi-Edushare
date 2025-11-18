import 'package:get/get.dart';

import '../controllers/detail_speech_controller.dart';

class DetailSpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailSpeechController>(() => DetailSpeechController());
  }
}

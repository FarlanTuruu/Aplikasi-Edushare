import 'package:get/get.dart';
import '../controllers/start_speech_controller.dart';

class StartSpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StartSpeechController());
  }
}

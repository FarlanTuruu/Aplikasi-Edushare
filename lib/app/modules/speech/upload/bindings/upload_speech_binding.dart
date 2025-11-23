import 'package:get/get.dart';
import '../controllers/upload_speech_controller.dart';

class UploadSpeechBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UploadSpeechController());
  }
}


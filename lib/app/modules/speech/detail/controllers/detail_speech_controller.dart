import 'package:get/get.dart';
import '../../list/controllers/list_speech_controller.dart';

class DetailSpeechController extends GetxController {
  late final TranscriptionItem transcription;

  @override
  void onInit() {
    super.onInit();
    transcription = Get.arguments as TranscriptionItem;
  }

  String get formattedDuration {
    final d = transcription.duration;
    if (d == null) return '-';
    final minutes = d ~/ 60;
    final seconds = d % 60;
    return '${minutes}m ${seconds}s';
  }
}

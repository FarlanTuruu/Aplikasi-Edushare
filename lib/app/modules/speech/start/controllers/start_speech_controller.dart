import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class StartSpeechController extends GetxController {
  final speech = stt.SpeechToText();

  var isRecording = false.obs;
  var recognizedText = "".obs;
  var hasSpeech = false.obs;
  var duration = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    hasSpeech.value = await speech.initialize(
      onStatus: (status) => print(status),
      onError: (error) => print(error),
    );
  }

  void startListening() async {
    if (!hasSpeech.value) return;
    isRecording.value = true;

    speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
      },
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void stopListening() {
    speech.stop();
    isRecording.value = false;
  }

  void toggleRecording() {
    if (isRecording.value) {
      stopListening();
    } else {
      startListening();
    }
  }
}

import 'package:get/get.dart';
import '../../list/controllers/list_speech_controller.dart';

class TrashSpeechController extends GetxController {
  final ListSpeechController listController = Get.find<ListSpeechController>();

  /// Items: gunakan list transcriptions dari ListSpeechController
  RxList<TranscriptionItem> get items => listController.transcriptions;

  /// Delete permanently via backend
  Future<void> deletePermanently(TranscriptionItem t) async {
    await listController.deleteTranscription(t);
  }
}

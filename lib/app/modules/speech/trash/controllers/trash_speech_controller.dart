import 'package:get/get.dart';
import '../../list/controllers/list_speech_controller.dart';

class TrashSpeechController extends GetxController {
  final listController = Get.find<ListSpeechController>();

  RxList<Recording> get trashRecordings =>
      listController.recordings.where((r) => r.isTrash).toList().obs;

  void restoreRecording(Recording rec) {
    final idx = listController.recordings.indexOf(rec);
    if (idx != -1) {
      listController.recordings[idx] = rec.copyWith(isTrash: false);
      listController.recordings.refresh();
    }
  }

  void deletePermanently(Recording rec) {
    listController.recordings.remove(rec);
  }
}

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';

class UploadSpeechController extends GetxController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  var isAvailable = false.obs;
  var isListening = false.obs;
  var recognizedText = ''.obs;
  var elapsedSeconds = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final hasPerm = await _requestMicPermission();
    if (!hasPerm) {
      isAvailable.value = false;
      return;
    }
    try {
      isAvailable.value = await _speech.initialize(
        onError: (error) => print('Speech init error: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );
    } catch (e) {
      isAvailable.value = false;
      print('Init speech exception: $e');
    }
  }

  Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  void startListening() {
    if (!isAvailable.value) return;
    recognizedText.value = '';
    isListening.value = true;
    _startTimer();
    _speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: true,
    );
  }

  void stopListening() {
    _speech.stop();
    isListening.value = false;
    _stopTimer();
  }

  void toggleListening() {
    if (isListening.value) {
      stopListening();
    } else {
      startListening();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    elapsedSeconds.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds.value++;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String get formattedTime {
    final s = elapsedSeconds.value % 60;
    final m = (elapsedSeconds.value ~/ 60) % 60;
    final h = (elapsedSeconds.value ~/ 3600);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: recognizedText.value));
    Get.snackbar('Copied', 'Teks disalin ke clipboard');
  }

  Future<void> shareText() async {
    if (recognizedText.value.trim().isEmpty) {
      Get.snackbar('Kosong', 'Tidak ada teks untuk dibagikan');
      return;
    }
    await Share.share(recognizedText.value);
  }

  @override
  void onClose() {
    _timer?.cancel();
    _speech.cancel();
    super.onClose();
  }
}

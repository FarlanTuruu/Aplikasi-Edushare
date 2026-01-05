import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:appedushare/app/data/api_client.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class StartSpeechController extends GetxController {
  final speech = stt.SpeechToText();
  static const String backendBaseUrl = 'https://your-backend-host';

  // state utama
  final isRecording = false.obs;
  final recognizedText = "".obs;
  final hasSpeech = false.obs;
  final duration = 0.obs;

  // state untuk proses simpan materi
  final isSaving = false.obs;

  Timer? _timer;
  String? _localeId; // kita pakai 'id_ID' untuk bahasa Indonesia

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  @override
  void onClose() {
    speech.stop();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _initSpeech() async {
    final available = await speech.initialize(
      onStatus: (status) => print("speech status: $status"),
      onError: (error) => print("speech error: $error"),
    );
    hasSpeech.value = available;

    if (available) {
      try {
        // coba ikuti bahasa system dulu
        final systemLocale = await speech.systemLocale();
        if (systemLocale!.localeId.toLowerCase().contains('id')) {
          _localeId = systemLocale?.localeId; // contoh: id_ID
        } else {
          _localeId = 'id_ID';
        }
      } catch (_) {
        _localeId = 'id_ID';
      }
    }
  }

  Future<void> startListening() async {
    if (!hasSpeech.value) {
      await _initSpeech();
      if (!hasSpeech.value) return;
    }

    isRecording.value = true;
    duration.value = 0;
    _startTimer();

    await speech.listen(
      onResult: (result) {
        // hasil speech to text (Bahasa Indonesia)
        recognizedText.value = result.recognizedWords;
      },
      localeId: _localeId ?? 'id_ID', // 🔴 PENTING: Bahasa Indonesia
      listenMode: stt.ListenMode.dictation, // cocok untuk materi panjang
      partialResults: true,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      duration.value++;
    });
  }

  Future<void> stopListening() async {
    await speech.stop();
    isRecording.value = false;
    _timer?.cancel();
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Dipanggil dari tombol "Simpan sebagai materi Edushare"
  Future<void> saveCurrentSpeech() async {
    final text = recognizedText.value.trim();
    if (text.isEmpty || isSaving.value) return;

    isSaving.value = true;
    try {
      await _api.postJson('speech', {
        'text': text,
        'source': 'live',
        'language': 'id-ID',
        'duration': duration.value,
      });

      Get.snackbar(
        'Berhasil',
        'Transkrip berhasil disimpan sebagai materi Edushare.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat menyimpan transkrip: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  ApiClient get _api {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    return Get.find<ApiClient>();
  }

  void clearCurrentSpeech() {
    recognizedText.value = "";
    duration.value = 0;
  }
}

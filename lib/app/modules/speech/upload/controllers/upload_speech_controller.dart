import 'dart:async';

import 'package:appedushare/app/data/api_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

class UploadSpeechController extends GetxController {
  final isListening = false.obs;
  final formattedTime = '00:00'.obs;
  final recognizedText = ''.obs;

  final AudioPlayer _player = AudioPlayer();
  PlatformFile? _file;
  bool _initialized = false;

  Duration? _audioDuration;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  Future<void> initWithFile(PlatformFile file, bool _) async {
    if (_initialized) return;
    _initialized = true;

    _file = file;

    if (file.path == null) {
      recognizedText.value = 'Path file tidak tersedia.';
      return;
    }

    try {
      await _player.setFilePath(file.path!);
      _audioDuration = _player.duration;
    } catch (e) {
      recognizedText.value = 'Gagal memuat file audio: $e';
      return;
    }

    _positionSub = _player.positionStream.listen((pos) {
      final total = _player.duration;
      if (total != null) {
        formattedTime.value =
            '${_formatDuration(pos)} / ${_formatDuration(total)}';
      } else {
        formattedTime.value = _formatDuration(pos);
      }
    });

    _stateSub = _player.playerStateStream.listen((state) {
      isListening.value = state.playing;
    });
  }

  Future<void> toggleListening() async {
    if (_file == null || _file!.path == null) {
      recognizedText.value = 'Tidak ada file audio yang bisa diputar.';
      return;
    }

    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();

        if (recognizedText.value.isEmpty ||
            recognizedText.value == 'Sedang melakukan transkripsi...') {
          _startTranscription(_file!.path!);
        }
      }
    } catch (e) {
      recognizedText.value = 'Gagal memutar audio: $e';
    }
  }

  Future<void> _startTranscription(String path) async {
    if (!_isSupportedFormat(path)) {
      recognizedText.value =
          'Format file ini belum didukung untuk transkripsi langsung.\n'
          'Gunakan file .wav, .flac, .mp3, atau voice note WhatsApp '
          '(.ogg / .opus).';
      return;
    }

    recognizedText.value = 'Sedang melakukan transkripsi...';
    try {
      final text = await transcribeFile(path);
      recognizedText.value = text;
      await saveRecognizedText();
    } catch (e) {
      recognizedText.value = 'Gagal melakukan transkripsi: $e';
    }
  }

  Future<String> transcribeFile(String path) async {
    final response = await _api.postWithFile(
      'speech/transcribe',
      'audio',
      path,
      const {'language': 'id-ID'},
    );

    final text = response['text'];
    if (text is! String || text.trim().isEmpty) {
      throw Exception('Server tidak mengembalikan hasil transkrip.');
    }

    return text.trim();
  }

  bool _isSupportedFormat(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.wav') ||
        lower.endsWith('.flac') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.opus');
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> saveRecognizedText() async {
    final text = recognizedText.value.trim();
    if (text.isEmpty) return;

    try {
      await _api.postJson('speech', {
        'text': text,
        'source': 'audio',
        'language': 'id-ID',
        'duration': (_audioDuration?.inSeconds ?? 0),
      });
    } catch (e) {
      recognizedText.value += '\n\n(Gagal menyimpan ke server): $e';
    }
  }

  ApiClient get _api {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    return Get.find<ApiClient>();
  }

  void shareText() {
    final text = recognizedText.value.trim();
    if (text.isEmpty) return;
    Share.share(text);
  }

  void copyToClipboard() {
    final text = recognizedText.value.trim();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.onClose();
  }
}

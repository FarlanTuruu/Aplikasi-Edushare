import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

class UploadSpeechController extends GetxController {
  /// 🔑 TARUH API KEY GOOGLE SPEECH-TO-TEXT KAMU DI SINI
  /// contoh: const String googleSpeechApiKey = 'AIzaSy...';
  static const String googleSpeechApiKey =
      'AIzaSyBvs_VVwJjoNgjZCW-8s9Zzth1zht2RAlQ';

  final isListening = false.obs;        // untuk state play/pause & waveform
  final formattedTime = '00:00'.obs;    // teks timer mm:ss
  final recognizedText = ''.obs;        // hasil transkrip

  final AudioPlayer _player = AudioPlayer();
  PlatformFile? _file;
  bool _isVideo = false;
  bool _initialized = false;            // supaya tidak re-init setiap build

  Duration? _audioDuration;            // sekarang tidak dipakai untuk blokir durasi

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void onInit() {
    super.onInit();
  }

  /// 🔹 Dipanggil dari UploadSpeechView dengan file hasil picker
  Future<void> initWithFile(PlatformFile file, bool isVideo) async {
    if (_initialized) return; // sudah pernah init
    _initialized = true;

    _file = file;
    _isVideo = isVideo;

    if (file.path == null) {
      recognizedText.value = 'Path file tidak tersedia.';
      return;
    }

    try {
      await _player.setFilePath(file.path!);
      // kalau kamu mau simpan durasi, boleh:
      _audioDuration = _player.duration;
    } catch (e) {
      recognizedText.value = 'Gagal memuat file audio: $e';
      return;
    }

    // listen posisi untuk update timer
    _positionSub = _player.positionStream.listen((pos) {
      final total = _player.duration;
      if (total != null) {
        formattedTime.value =
            '${_formatDuration(pos)} / ${_formatDuration(total)}';
      } else {
        formattedTime.value = _formatDuration(pos);
      }
    });

    // listen state untuk update isListening
    _stateSub = _player.playerStateStream.listen((state) {
      isListening.value = state.playing;
    });
  }

  // 🔹 tombol play/pause di view
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

        // mulai transkripsi kalau belum ada
        if (recognizedText.value.isEmpty ||
            recognizedText.value == 'Sedang melakukan transkripsi...') {
          _startTranscription(_file!.path!);
        }
      }
    } catch (e) {
      recognizedText.value = 'Gagal memutar audio: $e';
    }
  }

  /// 🔹 Mulai proses transkripsi
  /// Panjang audio TIDAK dibatasi di sini.
  /// Kalau kepanjangan, biar Google yang balas error dan teks error-nya
  /// akan tampil di `recognizedText`.
  Future<void> _startTranscription(String path) async {
    // 0️⃣ cek format dulu (biar yang aneh-aneh tidak dikirim)
    if (!_isSupportedFormat(path)) {
      recognizedText.value =
          'Format file ini belum didukung untuk transkripsi langsung.\n'
          'Gunakan file .wav, .mp3, atau voice note WhatsApp (.ogg / .opus).';
      return;
    }

    // ✅ TIDAK ADA LAGI CEK DURASI DI SINI

    recognizedText.value = 'Sedang melakukan transkripsi...';
    try {
      final text = await transcribeFile(path);
      recognizedText.value = text;
    } catch (e) {
      recognizedText.value = 'Gagal melakukan transkripsi (unexpected): $e';
    }
  }

  /// 🔹 Panggil Google Cloud Speech-to-Text
  /// Kalau terlalu panjang, Google akan balas:
  ///   "Sync input too long..." (400) → akan muncul di recognizedText
  Future<String> transcribeFile(String path) async {
  final file = File(path);

  if (!await file.exists()) {
    return 'File tidak ditemukan di path: $path';
  }

  // 1️⃣ Baca file audio → base64
  final bytes = await file.readAsBytes();
  final content = base64Encode(bytes);

  // 2️⃣ Tentukan encoding + (opsional) sample rate
  final encoding = _detectEncodingFromPath(path);
  final int? sampleRate = _detectSampleRateForEncoding(encoding);

  // 3️⃣ Config STT
  final Map<String, dynamic> config = {
    "encoding": encoding,
    "languageCode": "id-ID",
    "enableAutomaticPunctuation": true,
  };

  // khusus OGG_OPUS (WhatsApp .opus / .ogg) WAJIB kasih sampleRateHertz
  if (sampleRate != null) {
    config["sampleRateHertz"] = sampleRate;
  }

  // 4️⃣ Body request
  final body = jsonEncode({
    "config": config,
    "audio": {
      "content": content,
    }
  });

  print('[STT] Kirim request ke Google...');
  final response = await http.post(
    Uri.parse(
      'https://speech.googleapis.com/v1/speech:recognize?key=$googleSpeechApiKey',
    ),
    headers: {"Content-Type": "application/json"},
    body: body,
  );
  print('[STT] statusCode: ${response.statusCode}');
  print('[STT] body: ${response.body}');

  if (response.statusCode != 200) {
    // error Google dikembalikan apa adanya ke UI
    return 'Google STT error (${response.statusCode}): ${response.body}';
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  if (data["results"] == null) {
    return "Tidak ada hasil transkrip dari Google (results null).";
  }

  final results = data["results"] as List;

  final allTexts = results
      .map((r) =>
          ((r["alternatives"] as List?)?.first?["transcript"] ?? "") as String)
      .where((t) => t.trim().isNotEmpty)
      .join(" ");

  if (allTexts.trim().isEmpty) {
    return "Google tidak menemukan ucapan yang bisa dikenali (transcript kosong).";
  }

  return allTexts;
}
// encoding sesuai ekstensi
String _detectEncodingFromPath(String path) {
  final lower = path.toLowerCase();

  if (lower.endsWith('.wav')) return 'LINEAR16';
  if (lower.endsWith('.flac')) return 'FLAC';
  if (lower.endsWith('.ogg') || lower.endsWith('.opus')) return 'OGG_OPUS';
  if (lower.endsWith('.mp3')) return 'MP3';

  return 'MP3';
}

// sampleRate untuk encoding tertentu (khusus OGG_OPUS WAJIB)
int? _detectSampleRateForEncoding(String encoding) {
  switch (encoding) {
    case 'OGG_OPUS':
      // WhatsApp voice note biasanya 16 kHz; boleh juga 24000/48000
      return 16000;
    default:
      // MP3, WAV, FLAC bisa biarkan Google deteksi sendiri
      return null;
  }
}
  // format yang boleh dikirim langsung ke Google STT v1
  bool _isSupportedFormat(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.wav') ||
        lower.endsWith('.flac') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.opus');
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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

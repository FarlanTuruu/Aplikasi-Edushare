import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appedushare/app/data/api_client.dart';

class ListSpeechController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  /// Data transkripsi dari backend
  final transcriptions = <TranscriptionItem>[].obs;

  /// Filter data berdasarkan search
  List<TranscriptionItem> get filteredTranscriptions {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return transcriptions;
    return transcriptions
        .where((t) => (t.text ?? '').toLowerCase().contains(q))
        .toList();
  }

  /// Handler pencarian teks
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  /// Fetch data dari backend
  Future<void> fetchTranscriptions() async {
    try {
      final list = await _api.getList('speech');
      transcriptions.value = list
          .map((e) => TranscriptionItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal memuat transkrip: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Hapus transkripsi via backend
  Future<void> deleteTranscription(TranscriptionItem t) async {
    try {
      await _api.delete('speech/${t.id}');
      transcriptions.removeWhere((x) => x.id == t.id);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus transkrip: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  ApiClient get _api {
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }
    return Get.find<ApiClient>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchTranscriptions();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

/// ===== Model Data dari Backend =====
class TranscriptionItem {
  final int id;
  final String? text;
  final String? source;
  final String? language;
  final int? duration;
  final DateTime? createdAt;

  TranscriptionItem({
    required this.id,
    this.text,
    this.source,
    this.language,
    this.duration,
    this.createdAt,
  });

  factory TranscriptionItem.fromJson(Map<String, dynamic> json) {
    return TranscriptionItem(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String?,
      source: json['source'] as String?,
      language: json['language'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  String get snippet {
    final t = (text ?? '').trim();
    if (t.isEmpty) return '(kosong)';
    return t.length > 60 ? '${t.substring(0, 60)}…' : t;
  }
}

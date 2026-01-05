import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_speech_controller.dart';

class DetailSpeechView extends GetView<DetailSpeechController> {
  const DetailSpeechView({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A148C);

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F4FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard(purple),
                      const SizedBox(height: 20),
                      _transcriptionCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Detail Speech',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard(Color purple) {
    final t = controller.transcription;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(Icons.language, 'Language', t.language ?? '-'),
          const SizedBox(height: 12),
          _infoRow(Icons.schedule, 'Duration', controller.formattedDuration),
          const SizedBox(height: 12),
          _infoRow(Icons.mic, 'Source', t.source ?? '-'),
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today, 'Created', _formatDate(t.createdAt)),
        ],
      ),
    );
  }

  // ================= TRANSCRIPTION =================
  Widget _transcriptionCard() {
    final text = controller.transcription.text ?? '(Transcription kosong)';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transcription Text',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _infoRow(IconData icon, String label, String value) {
    const purple = Color(0xFF4A148C);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: purple, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day.toString().padLeft(2, '0')} '
        '${months[dt.month - 1]} ${dt.year} – '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

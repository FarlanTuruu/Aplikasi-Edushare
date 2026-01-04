// File: /lib/app/modules/speech/upload/views/upload_speech_view.dart

import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/upload_speech_controller.dart';
import '../../list/controllers/list_speech_controller.dart';
import '../../list/views/list_speech_view.dart';
import '../../trash/controllers/trash_speech_controller.dart';
import '../../trash/views/trash_speech_view.dart';

class UploadSpeechView extends GetView<UploadSpeechController> {
  const UploadSpeechView({Key? key}) : super(key: key);

  // Definisi Warna Utama - Konsisten dengan homepage & notes
  static const Color _primaryPurple = Color(0xFF4A148C);
  static const Color _secondaryPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    // 🔹 Ambil argumen dari Get.to(..., arguments: {...})
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final PlatformFile? file = args['file'] as PlatformFile?;

    // 🔹 Sangat penting: kirim file ke controller
    if (file != null) {
      controller.initWithFile(file, false);
    }

    return Scaffold(
      backgroundColor: _primaryPurple, // Konsisten dengan homepage & notes
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER - Konsisten dengan notes
            _buildHeader(context, isTablet),

            // 🔹 BODY PUTIH
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45), // Konsisten dengan notes
                    topRight: Radius.circular(45),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: isTablet ? 30 : 20,
                      right: isTablet ? 30 : 20,
                      bottom: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // 🔹 Tombol List & Trash - Konsisten dengan notes navigation
                        _buildNavigationMenu(isTablet),
                        const SizedBox(height: 20),

                        // 🔹 Tombol Mode (desain sama StartSpeechView)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _modeButton("Start", false),
                            _modeButton("Audio", false),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 🔹 Info file yang dipilih
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2D6F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.audiotrack,
                                color: purple,
                                size: 28,
                              ),

                              const SizedBox(width: 12),
                              Expanded(
                                child: file == null
                                    ? const Text(
                                        "Belum ada file dipilih.\n"
                                        "Silakan pilih file audio/video dari halaman sebelumnya.",
                                        style: TextStyle(fontSize: 13),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "File audio (termasuk voice note WhatsApp: OGG/OPUS) untuk ditranskripsi.",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Timer
                        Center(
                          child: Obx(
                            () => Text(
                              controller.formattedTime.value,
                              style: TextStyle(
                                fontSize: isTablet ? 42 : 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 🔹 Waveform animasi
                        _WaveformWidget(isPlaying: controller.isListening),
                        const SizedBox(height: 6),

                        // 🔹 Timeline (dummy)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '00:45',
                              style: TextStyle(fontSize: isTablet ? 13 : 12),
                            ),
                            Text(
                              '01:00',
                              style: TextStyle(fontSize: isTablet ? 13 : 12),
                            ),
                            Text(
                              '01:15',
                              style: TextStyle(fontSize: isTablet ? 13 : 12),
                            ),
                            Text(
                              '01:30',
                              style: TextStyle(fontSize: isTablet ? 13 : 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Tombol Play / Pause
                        Center(
                          child: Obx(
                            () => GestureDetector(
                              onTap: controller.toggleListening,
                              child: CircleAvatar(
                                radius: isTablet ? 42 : 36,
                                backgroundColor: _primaryPurple,
                                child: Icon(
                                  controller.isListening.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: isTablet ? 40 : 34,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 KOLUM TRANSKRIP
                        const Text(
                          "Transkrip materi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2D6F0)),
                          ),
                          child: Obx(
                            () => Text(
                              controller.recognizedText.value.isEmpty
                                  ? "Hasil transkrip dari file audio akan "
                                        "muncul di sini setelah proses selesai."
                                  : controller.recognizedText.value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Tombol Share & Copy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: controller.shareText,
                              icon: Icon(
                                Icons.share_outlined,
                                color: _primaryPurple,
                                size: isTablet ? 26 : 24,
                              ),
                            ),
                            IconButton(
                              onPressed: controller.copyToClipboard,
                              icon: Icon(
                                Icons.copy_outlined,
                                color: _primaryPurple,
                                size: isTablet ? 26 : 24,
                              ),
                            ),
                          ],
                        ),

                        // Spacer agar tidak tertutup bottom navbar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Nav - Konsisten dengan homepage & notes
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // TOP NAVBAR - Konsisten dengan notes
  // ============================================================
  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 40 : 24,
        isTablet ? 20 : 16,
        isTablet ? 40 : 24,
        isTablet ? 20 : 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Speech To Teks',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed('/settings/profile');
                },
                child: Container(
                  width: isTablet ? 48 : 40,
                  height: isTablet ? 48 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              GestureDetector(
                onTap: () {
                  // Navigate to settings
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: isTablet ? 32 : 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION MENU - Konsisten dengan notes
  // ============================================================
  Widget _buildNavigationMenu(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _menuButton('List', false, () {
            Get.delete<ListSpeechController>(force: true);
            Get.lazyPut(() => ListSpeechController());
            Get.to(() => const ListSpeechView());
          }, isTablet),
          const SizedBox(width: 12),
          _menuButton('Trash', false, () {
            Get.delete<TrashSpeechController>(force: true);
            Get.lazyPut(() => TrashSpeechController());
            Get.to(() => const TrashSpeechView());
          }, isTablet),
        ],
      ),
    );
  }

  Widget _menuButton(
    String text,
    bool active,
    VoidCallback action,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 18,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30), // Konsisten dengan notes
          border: Border.all(
            color: Colors.black, // Konsisten dengan notes
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // 🔸 Tombol mode (Audio / Start / Video)
  Widget _modeButton(String label, bool isActiveIgnored, bool isTablet) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 18,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: _primaryPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 14 : 13,
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVBAR - Konsisten dengan Homepage & Notes
  // ============================================================
  Widget _buildBottomNavigation() {
    return Container(
      height: 80, // Konsisten dengan homepage & notes
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home Button
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () => Get.toNamed('/homepage'),
          ),

          // Chat Button
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () => Get.toNamed('/chat/rooms'),
          ),

          // Add Button
          GestureDetector(
            onTap: () {
              _showCreateActionDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black54, size: 24),
            ),
          ),

          // Mic Button (Active - karena di halaman speech)
          GestureDetector(
            onTap: () => Get.toNamed('/speech/list'),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _primaryPurple, // Active state
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CREATE ACTION DIALOG - Sama dengan notes
  // ============================================================
  void _showCreateActionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Materi Or\nCatatan Colaboration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCreateOptionButton(
                    title: 'Materi',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/notes/create');
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildCreateOptionButton(
                    title: 'Catatan',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/collab/create');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOptionButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 100,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const CircleBorder(),
            elevation: 4,
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// 🔹 Waveform animasi bergerak selama audio diputar (visual saja)
class _WaveformWidget extends StatefulWidget {
  final RxBool isPlaying;
  const _WaveformWidget({Key? key, required this.isPlaying}) : super(key: key);

  @override
  State<_WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<_WaveformWidget> {
  int _tick = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        if (widget.isPlaying.value) {
          _tick++;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A148C);

    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(20, (i) {
          final playing = widget.isPlaying.value;

          final baseHeight = playing ? 18.0 : 10.0;
          final variableHeight = playing
              ? (((i + _tick) % 5) * 6).toDouble()
              : ((i % 3) * 4).toDouble();

          final height = baseHeight + variableHeight;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 6,
            height: height,
            decoration: BoxDecoration(
              color: i % 2 == 0 ? purple : Colors.grey[350],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

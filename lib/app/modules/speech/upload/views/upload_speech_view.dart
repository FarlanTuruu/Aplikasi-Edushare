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

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A1F7A);

    // 🔹 Ambil argumen dari popup upload
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final PlatformFile? file = args['file'] as PlatformFile?;
    final bool isVideo = args['isVideo'] == true;

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Speech To Teks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CircleAvatar(radius: 20),
                ],
              ),
            ),

            // 🔹 BODY PUTIH
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Tombol List & Trash
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _whiteButton('List', onTap: () {
                            Get.delete<ListSpeechController>(force: true);
                            Get.lazyPut(() => ListSpeechController());
                            Get.to(() => const ListSpeechView());
                          }),
                          const SizedBox(width: 10),
                          _whiteButton('Trash', onTap: () {
                            Get.delete<TrashSpeechController>(force: true);
                            Get.lazyPut(() => TrashSpeechController());
                            Get.to(() => const TrashSpeechView());
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Mode (Video / Audio / Start)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _modeButton('Video', isVideo),
                          _modeButton('Audio', !isVideo),
                          _modeButton('Start', false),
                        ],
                      ),
                      const SizedBox(height: 20),

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
                            Icon(
                              isVideo ? Icons.videocam_outlined : Icons.audiotrack,
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
                                        Text(
                                          isVideo
                                              ? "File video untuk diambil audionya dan ditranskripsi."
                                              : "File audio (termasuk voice note WhatsApp: OGG/OPUS) untuk ditranskripsi.",
                                          style: const TextStyle(
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
                            controller.formattedTime,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🔹 Waveform
                      _WaveformWidget(isPlaying: controller.isListening),
                      const SizedBox(height: 6),

                      // 🔹 Timeline (dummy)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('00:45', style: TextStyle(fontSize: 12)),
                          Text('01:00', style: TextStyle(fontSize: 12)),
                          Text('01:15', style: TextStyle(fontSize: 12)),
                          Text('01:30', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Tombol Play / Pause
                      Center(
                        child: Obx(
                          () => GestureDetector(
                            onTap: controller.toggleListening,
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: purple,
                              child: Icon(
                                controller.isListening.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                      ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Kotak teks hasil transkrip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Obx(
                          () => Text(
                            controller.recognizedText.value.isEmpty
                                ? "Hasil transkrip dari file audio/video akan "
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
                            icon: const Icon(
                              Icons.share_outlined,
                              color: purple,
                            ),
                          ),
                          IconButton(
                            onPressed: controller.copyToClipboard,
                            icon: const Icon(
                              Icons.copy_outlined,
                              color: purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Nav (seragam & mic di lingkaran ungu)
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // 🔸 Tombol putih (List & Trash)
  Widget _whiteButton(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 🔸 Tombol mode (Video / Audio / Start)
  Widget _modeButton(String label, bool isActive) {
    const purple = Color(0xFF4A1F7A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? purple : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : purple,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  // 🔸 Bottom Navigation (seragam dengan StartSpeechView)
  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home_outlined, false, () {
            Get.toNamed('/homepage');
          }),
          _buildBottomNavItem(Icons.chat_bubble_outline, false, () {
            Get.toNamed('/chat/rooms');
          }),
          _buildBottomNavItem(Icons.add_circle, false, () {
            Get.toNamed('/notes/create');
          }),
          _buildBottomNavItem(Icons.mic_outlined, true, () {
            Get.toNamed('/speech/list');
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, bool isCenter, VoidCallback onTap) {
    const purple = Color(0xFF4A1F7A);

    if (isCenter) {
      // tombol mic: lingkaran ungu
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: Colors.grey[800],
      ),
      onPressed: onTap,
    );
  }
}

/// 🔹 Waveform animasi
class _WaveformWidget extends StatelessWidget {
  final RxBool isPlaying;
  const _WaveformWidget({Key? key, required this.isPlaying}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A1F7A);
    return Obx(() {
      return SizedBox(
        height: 70,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(20, (i) {
            final height =
                isPlaying.value ? (15 + (i * 5) % 50) : 10 + (i % 5) * 5;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 6,
              height: height.toDouble(),
              decoration: BoxDecoration(
                color: i % 2 == 0 ? purple : Colors.grey[350],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      );
    });
  }
}

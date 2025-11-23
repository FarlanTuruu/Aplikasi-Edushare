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
                  Text("Speech To Teks",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  CircleAvatar(radius: 20)
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

                      // 🔹 Tombol Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _modeButton('Video'),
                          _modeButton('Audio'),
                          _modeButton('Start'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Timer
                      Obx(() => Text(
                            controller.formattedTime,
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(height: 15),

                      // 🔹 Waveform
                      _WaveformWidget(isPlaying: controller.isListening),
                      const SizedBox(height: 6),

                      // 🔹 Timeline
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
                      Obx(() => GestureDetector(
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
                          )),
                      const SizedBox(height: 20),

                      // 🔹 Kotak teks hasil transkrip
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Obx(() => Text(
                              controller.recognizedText.value.isEmpty
                                  ? "Serangan terhadap warga Asia New York baru-baru ini menyebabkan empat kematian. Yao Pan Ma, seorang imigran Cina"
                                  : controller.recognizedText.value,
                              style: const TextStyle(fontSize: 16),
                            )),
                      ),
                      const SizedBox(height: 12),

                      // 🔹 Tombol Share & Copy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: controller.shareText,
                            icon: const Icon(Icons.share_outlined,
                                color: purple),
                          ),
                          IconButton(
                            onPressed: controller.copyToClipboard,
                            icon: const Icon(Icons.copy_outlined,
                                color: purple),
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

      // 🔹 Bottom Nav (seragam dengan StartSpeechView)
      bottomNavigationBar: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.home, size: 32),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_outlined, size: 32),
                Positioned(
                  right: -1,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    
                  ),
                ),
              ],
            ),
            const Icon(Icons.add_circle_outline, size: 38),
            CircleAvatar(
              radius: 22,
              backgroundColor: purple,
              child: const Icon(Icons.mic, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
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
        child: Text(label),
      ),
    );
  }

  // 🔸 Tombol mode (Video / Audio / Start)
  Widget _modeButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4A1F7A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
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

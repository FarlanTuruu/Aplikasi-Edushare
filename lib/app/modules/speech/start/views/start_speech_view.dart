import 'package:appedushare/app/modules/speech/upload/controllers/upload_speech_controller.dart';
import 'package:appedushare/app/modules/speech/upload/views/upload_speech_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/start_speech_controller.dart';
import '../../list/controllers/list_speech_controller.dart';
import '../../list/views/list_speech_view.dart';
import '../../trash/controllers/trash_speech_controller.dart';
import '../../trash/views/trash_speech_view.dart';

class StartSpeechView extends GetView<StartSpeechController> {
  const StartSpeechView({super.key});

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _modeButton("Video", onTap: () {
                            _showUploadDialog(context);
                          }),
                          _modeButton("Audio", onTap: () {
                            _showUploadDialog(context);
                          }),
                          _modeButton("Start"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("Recording...",
                          style: TextStyle(fontSize: 18, color: Colors.black)),
                      const SizedBox(height: 20),

                      // 🔹 Tombol Mic
                      Obx(() => GestureDetector(
                            onTap: controller.toggleRecording,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: purple,
                              child: Icon(
                                controller.isRecording.value
                                    ? Icons.pause
                                    : Icons.mic,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          )),
                      const SizedBox(height: 20),

                      // 🔹 Hasil Transkripsi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Obx(() => Text(
                              controller.recognizedText.value.isEmpty
                                  ? "Mulai bicara untuk memulai transkripsi..."
                                  : controller.recognizedText.value,
                              style: const TextStyle(fontSize: 16),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bottom Nav
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

  // 🔸 Popup Upload
  void _showUploadDialog(BuildContext context) {
    const purple = Color(0xFF4A1F7A);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Upload",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color(0xFFD2C4E0)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 42, color: Color(0xFF4A1F7A)),
                      SizedBox(height: 10),
                      Text.rich(TextSpan(
                        text: 'Drag & drop files or ',
                        style: TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Browse',
                            style: TextStyle(
                                color: Color(0xFF4A1F7A),
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )),
                      SizedBox(height: 5),
                      Text(
                        "Supported formats: JPEG, PNG, GIF, MP4, PDF, PSD, AI, Word, PPT",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Get.put(UploadSpeechController());
                      Get.back();
                      Get.to(() => const UploadSpeechView());
                    },
                    child: const Text("UPLOAD FILES",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔸 Tombol Putih (List & Trash)
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

  // 🔸 Tombol Mode
  Widget _modeButton(String label, {VoidCallback? onTap}) {
    const purple = Color(0xFF4A1F7A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

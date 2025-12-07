import 'package:appedushare/app/modules/speech/upload/controllers/upload_speech_controller.dart';
import 'package:appedushare/app/modules/speech/upload/views/upload_speech_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/start_speech_controller.dart';
import '../../list/controllers/list_speech_controller.dart';
import '../../list/views/list_speech_view.dart';
import '../../trash/controllers/trash_speech_controller.dart';
import '../../trash/views/trash_speech_view.dart';
import 'package:file_picker/file_picker.dart';


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
                  Text(
                    "Speech To Teks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                  ),
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

                      // 🔹 Info kecil tentang fitur
                      const SizedBox(height: 16),

                      // 🔹 Tombol Mode (Rekaman langsung / Upload)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _modeButton("Start"),
                          _modeButton(
                            "Audio",
                            onTap: () {
                              _showUploadDialog(context, isVideo: false);
                            },
                          ),
                          _modeButton(
                            "Video",
                            onTap: () {
                              _showUploadDialog(context, isVideo: true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 🔹 Status rekaman (dinamis)
                      Obx(
                        () => Center(
                          child: Text(
                            controller.isRecording.value
                                ? "Sedang merekam materi..."
                                : "Siap merekam materi kuliah",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Tombol Mic (Record / Pause)
                      Center(
                        child: Obx(
                          () => GestureDetector(
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Hasil Transkripsi
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
                        border: Border.all(
                          color: const Color(0xFFE2D6F0),
                        ),
                      ),
                      child: Obx(
                        () => Text(
                          controller.recognizedText.value.isEmpty
                              ? "Mulai bicara setelah menekan tombol mic.\n\n"
                                "Transkrip (Bahasa Indonesia) akan muncul di sini."
                              : controller.recognizedText.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                      const SizedBox(height: 16),

                      // 🔹 Tombol Simpan ke Edushare
                      Obx(
                        () {
                          final hasText = controller.recognizedText.value
                              .trim()
                              .isNotEmpty;

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save_outlined),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: purple,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: hasText
                              ? () {
                                  controller.saveCurrentSpeech();
                                }
                              : null,

                              label: const Text(
                                "Simpan sebagai materi Edushare",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Rekaman dan transkrip yang disimpan akan muncul di menu List "
                              "dan bisa kamu bagikan ke teman kamu.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
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

      // 🔹 Bottom Nav (sesuai contoh)
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // 🔸 Popup Upload
// 🔸 Popup Upload
void _showUploadDialog(BuildContext context, {bool isVideo = false}) {
  const purple = Color(0xFF4A1F7A);

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      PlatformFile? selectedFile;
      String? errorText;

      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickFile() async {
            // 🔹 Langsung buka file picker (tanpa permission_handler)
            final result = await FilePicker.platform.pickFiles(
              type: isVideo ? FileType.video : FileType.custom,
              allowedExtensions: isVideo
                  ? ['mp4', 'mkv', 'mov']
                  : [
                      'mp3',
                      'wav',
                      'm4a',
                      'aac',
                      'ogg',  // voice note WA
                      'opus', // voice note WA
                    ],
            );

            if (result != null && result.files.isNotEmpty) {
              setState(() {
                selectedFile = result.files.single;
                errorText = null;
              });
            }
          }

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isVideo
                        ? "Upload materi dari video"
                        : "Upload materi dari audio",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Area pilih file
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F0FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD2C4E0)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: pickFile,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 42,
                            color: Color(0xFF4A1F7A),
                          ),
                          const SizedBox(height: 10),
                          const Text.rich(
                            TextSpan(
                              text: 'Pilih file dari perangkat atau ',
                              style: TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: 'Browse',
                                  style: TextStyle(
                                    color: Color(0xFF4A1F7A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isVideo
                                ? "Format video: MP4, MKV, MOV"
                                : "Format audio: MP3, WAV, M4A, AAC, OGG, OPUS",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🔹 Nama file terpilih
                          if (selectedFile != null) ...[
                            const Divider(
                              indent: 24,
                              endIndent: 24,
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  Text(
                                    selectedFile!.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${(selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 🔹 Error text (belum pilih file)
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 🔹 Tombol LANJUTKAN UPLOAD
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (selectedFile == null) {
                          setState(() {
                            errorText =
                                'Silakan pilih file audio/video terlebih dahulu.';
                          });
                          return;
                        }

                        // siapkan controller upload kalau pakai GetX
                        Get.put(UploadSpeechController(), permanent: false);

                        // tutup dialog
                        Get.back();

                        // kirim file ke halaman upload
                        Get.to(
                          () => const UploadSpeechView(),
                          arguments: {
                            'file': selectedFile,
                            'isVideo': isVideo,
                          },
                        );
                      },
                      child: const Text(
                        "LANJUTKAN UPLOAD",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // 🔸 Bottom Navigation (sesuai contoh struktur)
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
      // tombol tengah (add) dibuat lebih menonjol
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
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
      onPressed: onTap,
    );
  }
}
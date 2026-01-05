// File: /lib/app/modules/speech/start/views/start_speech_view.dart

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
import 'package:appedushare/app/routes/app_pages.dart';
import 'package:appedushare/app/modules/settings/profile/controllers/profile_settings_controller.dart';

class StartSpeechView extends GetView<StartSpeechController> {
  const StartSpeechView({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A148C);

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER DINAMIS (SAMA SEPERTI HOMEPAGE & ROOMS)
            _buildHeader(purple),

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
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Tombol List & Trash
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _whiteButton(
                            'List',
                            onTap: () {
                              Get.delete<ListSpeechController>(force: true);
                              Get.lazyPut(() => ListSpeechController());
                              Get.to(() => const ListSpeechView());
                            },
                          ),
                          const SizedBox(width: 10),
                          _whiteButton(
                            'Trash',
                            onTap: () {
                              Get.delete<TrashSpeechController>(force: true);
                              Get.lazyPut(() => TrashSpeechController());
                              Get.to(() => const TrashSpeechView());
                            },
                          ),
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
                          border: Border.all(color: const Color(0xFFE2D6F0)),
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
                      Obx(() {
                        final hasText = controller.recognizedText.value
                            .trim()
                            .isNotEmpty;

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save_outlined),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                      }),

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

      // 🔹 Bottom Nav (konsisten dengan homepage)
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // 🔸 HEADER DINAMIS - Load data dari ProfileSettingsController
  Widget _buildHeader(Color purple) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Speech To Teks',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              // Avatar Profil Dinamis
              GestureDetector(
                onTap: () => Get.toNamed(Routes.PROFILE),
                child: Obx(() {
                  final p = _profileCtrl;
                  final name = p.userName.value;
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                  final provider = _avatarProvider(p);

                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      color: provider == null
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: provider != null
                        ? ClipOval(
                            child: Image(
                              image: provider,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              // Icon Settings
              GestureDetector(
                onTap: () => Get.toNamed(Routes.PROFILE),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔸 Helper: Ensure ProfileSettingsController exists
  ProfileSettingsController get _profileCtrl {
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.put(ProfileSettingsController(), permanent: true);
    }
    return Get.find<ProfileSettingsController>();
  }

  // 🔸 Helper: Build avatar image provider dari resolved profile URL
  ImageProvider<Object>? _avatarProvider(ProfileSettingsController p) {
    final url = p.profileImageUrl.value;
    if (url.isEmpty) return null;
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    return null;
  }

  // 🔸 Popup Upload
  void _showUploadDialog(BuildContext context, {bool isVideo = false}) {
    const purple = Color(0xFF4A148C);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        PlatformFile? selectedFile;
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickFile() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'opus'],
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
                              color: Color(0xFF4A148C),
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
                                      color: Color(0xFF4A148C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Format audio: MP3, WAV, M4A, AAC, OGG, OPUS",
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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

                    // 🔹 Error text
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
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

                          Get.put(UploadSpeechController(), permanent: false);
                          Get.back();

                          Get.to(
                            () => const UploadSpeechView(),
                            arguments: {'file': selectedFile},
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
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  // 🔸 Tombol Mode
  Widget _modeButton(String label, {VoidCallback? onTap}) {
    const purple = Color(0xFF4A148C);
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

  // 🔸 Bottom Navigation (KONSISTEN DENGAN HOMEPAGE)
  Widget _buildBottomNavigation() {
    const purple = Color(0xFF4A148C);

    return Container(
      height: 80,
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
          // Tombol Home
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black54, size: 28),
            onPressed: () {
              Get.toNamed('/homepage');
            },
          ),

          // Tombol Chat
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              Get.toNamed('/chat/rooms');
            },
          ),

          // Tombol Tambah (Add) - Show dialog
          GestureDetector(
            onTap: _showCreateActionDialog,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black54, size: 24),
            ),
          ),

          // Tombol Mic Aktif (halaman speech)
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 Dialog Create Action (SAMA SEPERTI DI HOMEPAGE)
  void _showCreateActionDialog() {
    const purple = Color(0xFF4A148C);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buat Konten Baru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Tombol Upload Materi
              _dialogActionButton(
                icon: Icons.note_add_outlined,
                label: 'Upload Materi',
                onTap: () {
                  Get.back();
                  Get.toNamed('/notes/create');
                },
              ),
              const SizedBox(height: 12),

              // Tombol Upload Catatan
              _dialogActionButton(
                icon: Icons.upload_file_outlined,
                label: 'Upload Catatan',
                onTap: () {
                  Get.back();
                  Get.toNamed('/collab/create');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 Dialog Action Button Helper
  Widget _dialogActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const purple = Color(0xFF4A148C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: purple, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

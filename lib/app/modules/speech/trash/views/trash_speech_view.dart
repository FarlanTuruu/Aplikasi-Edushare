// Ganti seluruh class TrashSpeechView di trash_speech_view.dart dengan kode berikut:

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/trash_speech_controller.dart';
import '../../list/controllers/list_speech_controller.dart';
import '../../list/views/list_speech_view.dart';

class TrashSpeechView extends GetView<TrashSpeechController> {
  const TrashSpeechView({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A1F7A);

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Speech To Teks",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Row(
                    children: const [
                      CircleAvatar(radius: 20),
                      SizedBox(width: 8),
                      Icon(Icons.settings, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // BODY
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LIST / TRASH BUTTON
                      Row(
                        children: [
                          _pillButton(
                            "List",
                            isActive: false,
                            onTap: () {
                              Get.delete<ListSpeechController>(force: true);
                              Get.lazyPut(() => ListSpeechController());
                              Get.off(() => const ListSpeechView());
                            },
                          ),
                          const SizedBox(width: 10),
                          _pillButton("Trash", isActive: true, onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // TRASH LIST
                      Expanded(
                        child: Obx(() {
                          final items = controller.trashRecordings;
                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                "Trash is empty",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final rec = items[index];
                              return _trashCard(context, rec, purple);
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION (KONSISTEN DENGAN HOMEPAGE)
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // 🔸 Bottom Navigation (KONSISTEN DENGAN HOMEPAGE)
  Widget _buildBottomNavigation() {
    const purple = Color(0xFF4A1F7A);

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

          // Tombol Mic Aktif (halaman speech) - tetap bisa diklik
          GestureDetector(
            onTap: () {
              Get.toNamed('/speech/start');
            },
            child: Container(
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
          ),
        ],
      ),
    );
  }

  // 🔸 Dialog Create Action (SAMA SEPERTI DI HOMEPAGE)
  void _showCreateActionDialog() {
    const purple = Color(0xFF4A1F7A);

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

              // Tombol Buat Catatan Kolaborasi
              _dialogActionButton(
                icon: Icons.note_add_outlined,
                label: 'Upload Materi',
                onTap: () {
                  Get.back();
                  Get.toNamed('/notes/create');
                },
              ),
              const SizedBox(height: 12),

              // Tombol Upload Materi
              _dialogActionButton(
                icon: Icons.upload_file_outlined,
                label: 'Upload Catatan',
                onTap: () {
                  Get.back();
                  Get.toNamed('/collab/create');
                },
              ),
              const SizedBox(height: 12),
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
    const purple = Color(0xFF4A1F7A);

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

  // LIST / TRASH BUTTON
  Widget _pillButton(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // TRASH CARD
  Widget _trashCard(BuildContext context, Recording rec, Color purple) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: purple, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.green),
            onPressed: () => controller.restoreRecording(rec),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {
              _showDeleteDialog(context, rec, purple);
            },
          ),
        ],
      ),
    );
  }

  // DELETE CONFIRMATION
  void _showDeleteDialog(BuildContext context, Recording rec, Color purple) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9D84C8), Color(0xFF4A1F7A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure to\nDELETE this voice?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "No",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Get.back();
                      controller.deletePermanently(rec);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

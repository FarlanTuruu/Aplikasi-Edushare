// File: /lib/app/modules/speech/list/views/list_speech_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/list_speech_controller.dart';
import '../../trash/controllers/trash_speech_controller.dart';
import '../../trash/views/trash_speech_view.dart';
import 'package:appedushare/app/routes/app_pages.dart';
import 'package:appedushare/app/modules/settings/profile/controllers/profile_settings_controller.dart';

class ListSpeechView extends GetView<ListSpeechController> {
  const ListSpeechView({super.key});

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
                      // SEARCH
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search",
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // LIST / TRASH BUTTON
                      Row(
                        children: [
                          _pillButton("List", isActive: true, onTap: () {}),
                          const SizedBox(width: 10),
                          _pillButton(
                            "Trash",
                            isActive: false,
                            onTap: () {
                              Get.put(TrashSpeechController());
                              Get.to(() => const TrashSpeechView());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FILTER: dihapus untuk backend, pakai search saja
                      const SizedBox.shrink(),
                      const SizedBox(height: 16),

                      // LIST RECORDINGS
                      Expanded(
                        child: Obx(() {
                          final items = controller.filteredTranscriptions;
                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                "No recordings found.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final t = items[index];
                              return _recordingCard(
                                context: context,
                                transcription: t,
                                purple: purple,
                                controller: controller,
                              );
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

  Widget _pillButton(
    String label, {
    required bool isActive,
    VoidCallback? onTap,
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
            color: isActive ? Colors.black : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _recordingCard({
    required BuildContext context,
    required TranscriptionItem transcription,
    required Color purple,
    required ListSpeechController controller,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Get.toNamed('/speech/detail', arguments: transcription);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ▶️ ICON PLAY
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: purple, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white),
            ),
            const SizedBox(width: 12),

            // 📝 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transcription.snippet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(transcription.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🗑 DELETE (STOP PROPAGATION)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showDeleteDialog(context, controller, transcription, purple);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ListSpeechController controller,
    TranscriptionItem t,
    Color purple,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9D84C8), Color(0xFF4A148C)],
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
                  _roundedButton("No", Colors.white, purple, () => Get.back()),
                  _roundedButton("Yes", purple, Colors.white, () {
                    Get.back();
                    controller.deleteTranscription(t);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundedButton(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    // Simple formatting: dd MMM yyyy – HH:mm
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
    final d = dt.day.toString().padLeft(2, '0');
    final m = months[dt.month - 1];
    final y = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d $m $y – $hh:$mm';
  }
}

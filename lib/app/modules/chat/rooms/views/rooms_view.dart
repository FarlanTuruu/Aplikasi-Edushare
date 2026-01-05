// File: /lib/app/modules/chat/rooms/views/rooms_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';
import 'package:appedushare/app/routes/app_pages.dart';
import 'package:appedushare/app/modules/settings/profile/controllers/profile_settings_controller.dart';

class RoomsView extends GetView<RoomsController> {
  const RoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A148C);

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER DINAMIS (SAMA SEPERTI HOMEPAGE)
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // 🔸 Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: TextField(
                          onChanged: controller.onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔸 Daftar Chat
                      Expanded(
                        child: Obx(() {
                          final rooms = controller.filteredRooms;
                          if (rooms.isEmpty) {
                            return const Center(
                              child: Text(
                                'Belum ada percakapan',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return _chatTile(room);
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

      // 🔹 Bottom Navigation Bar (KONSISTEN DENGAN HOMEPAGE)
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // 🔸 HEADER DINAMIS - Load data dari ProfileSettingsController
  Widget _buildHeader(Color purple) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Baris Atas: Judul & Profil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chat',
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
                      final initial = name.isNotEmpty
                          ? name[0].toUpperCase()
                          : '?';
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
          const SizedBox(height: 20),
          // Search Bar dihapus karena sudah ada di body
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

          // Tombol Chat Aktif
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 28,
            ),
          ),

          // Tombol Tambah
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

          // Tombol Mic
          IconButton(
            icon: const Icon(
              Icons.mic_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              Get.toNamed('/speech/start');
            },
          ),
        ],
      ),
    );
  }

  // 🔸 Dialog Create Action
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

              _dialogActionButton(
                icon: Icons.note_add_outlined,
                label: 'Upload Materi',
                onTap: () {
                  Get.back();
                  Get.toNamed('/notes/create');
                },
              ),
              const SizedBox(height: 12),

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

  // 🔹 Chat Item dengan Navigasi ke MessagesView
  Widget _chatTile(Map<String, dynamic> room) {
    return ListTile(
      leading: (room['avatar'] != null && room['avatar'].toString().isNotEmpty)
          ? CircleAvatar(backgroundImage: NetworkImage(room['avatar']))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(
        room['name']?.toString() ?? '-',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        room['status']?.toString() ?? '',
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        Get.toNamed(
          Routes.CHAT_MESSAGES,
          arguments: {
            'conversationId':
                room['conversation_id'] ?? room['conversationId'] ?? room['id'],
            'roomId': room['id'],
            'userId':
                room['other_user_id'] ?? room['user_id'] ?? room['peer_id'],
            'contactName': room['name'],
            'avatar': room['avatar'],
            'room': room,
            'is_following': room['is_following'] ?? room['isFollowing'],
          },
        );
      },
    );
  }
}

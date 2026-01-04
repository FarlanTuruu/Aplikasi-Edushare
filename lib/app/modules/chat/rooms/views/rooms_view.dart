// Ganti seluruh class RoomsView di rooms_view.dart dengan kode berikut:

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';
import 'package:appedushare/app/routes/app_pages.dart';

class RoomsView extends GetView<RoomsController> {
  const RoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A1F7A);

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Chat",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.settings, color: Colors.white),
                    ],
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

          // Tombol Chat Aktif (halaman chat)
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

  // 🔹 Chat Item dengan Navigasi ke MessagesView
  Widget _chatTile(Map<String, dynamic> room) {
    // room: {id, name, avatar, ...}
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
        // Navigate via named route so MessagesBinding provides controller
        Get.toNamed(
          Routes.CHAT_MESSAGES,
          arguments: {
            // Prefer explicit conversation id if available
            'conversationId':
                room['conversation_id'] ?? room['conversationId'] ?? room['id'],
            'roomId': room['id'],
            // Try to provide the peer user id for DM ensure fallback
            'userId':
                room['other_user_id'] ?? room['user_id'] ?? room['peer_id'],
            'contactName': room['name'],
            'avatar': room['avatar'],
            // Provide full room map for additional inference in controller
            'room': room,
            // Pass following status if available so header icon can hide
            'is_following': room['is_following'] ?? room['isFollowing'],
          },
        );
      },
    );
  }
}

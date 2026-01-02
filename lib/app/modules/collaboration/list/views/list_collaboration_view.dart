import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_collaboration_controller.dart';

class ListCollaborationView extends GetView<ListCollaborationController> {
  const ListCollaborationView({super.key});

  // Warna Ungu Utama diambil dari sampel desain
  final Color _primaryPurple = const Color(0xFF512188);
  final Color _secondaryPurple = const Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background scaffold menjadi ungu agar area status bar juga ungu
      backgroundColor: _primaryPurple,
      body: Stack(
        children: [
          // ================= MAIN CONTENT STRUCTURE =================
          // Menggunakan Column agar area putih otomatis mengisi ruang tersisa di bawah header
          Column(
            children: [
              // 1. HEADER AREA (Di atas background ungu)
              _buildHeaderArea(),

              // 2. WHITE BODY AREA (Area melengkung yang mengisi sisa layar)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    // Lengkungan di pojok kiri atas
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                    ),
                  ),
                  // ClipRRect penting agar konten list yang di-scroll tidak "bocor" keluar dari lengkungan
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.collaborations.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        // Padding penting! Bottom padding besar agar item terakhir tidak tertutup Nav Bar
                        padding: const EdgeInsets.only(
                          top: 30,
                          left: 20,
                          right: 20,
                          bottom: 100,
                        ),
                        itemCount: controller.collaborations.length,
                        itemBuilder: (context, index) {
                          return _buildCollaborationCard(
                            controller.collaborations[index],
                            index,
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),

          // ================= BOTTOM NAVIGATION BAR =================
          // Diletakkan dalam Stack paling bawah (render terakhir) agar mengambang di atas konten
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavBar()),
        ],
      ),
    );
  }

  // WIDGET: Header Area (Back button, Title, Profile, Settings)
  Widget _buildHeaderArea() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Catatan Upload',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Profil Image (Circle Avatar)
            GestureDetector(
              onTap: controller.goToProfile,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  image: const DecorationImage(
                    // Ganti URL ini dengan gambar profil asli Anda
                    image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Settings Icon
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              onPressed: controller.goToSettings,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET: Kartu Item List
  Widget _buildCollaborationCard(Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Gradient Background: Kiri terang, Kanan gelap (sesuai desain)
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade100.withOpacity(0.7), // Kiri agak transparan
            _secondaryPurple, // Kanan ungu pekat
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Kotak Tanggal Putih
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['date'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    data['day'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Judul Item
            Expanded(
              child: Text(
                data['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // Warna teks hitam agar kontras di bagian kiri gradient yang terang
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Tombol Edit & Delete (Bentuk Pill/Kapsul Putih)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton(
                  'Edit',
                  () => controller.editCollaboration(index),
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Delete',
                  () => controller.deleteCollaboration(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk tombol kecil (Edit/Delete)
  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Lebar tetap agar seragam
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // WIDGET: Bottom Navigation Bar Custom
  Widget _buildBottomNavBar() {
    return Container(
      height: 80, // Tinggi navbar
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        // Shadow di atas navbar
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              // Navigasi ke halaman messages (chat)
              Get.toNamed('/homepage');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 26,
            ),
            onPressed: () {
              // Navigasi ke halaman messages (chat)
              Get.toNamed('/chat/rooms');
            },
          ),
          // Tombol Tambah Tengah (Floating Style)
          GestureDetector(
            onTap: controller.openAddMenu,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primaryPurple, // Warna ungu tombol tengah
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryPurple.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.mic_none_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: controller.navigateToVoice,
          ),
        ],
      ),
    );
  }

  // WIDGET: State Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada catatan",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

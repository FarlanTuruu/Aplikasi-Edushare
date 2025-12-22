import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/homepage_controller.dart';

class HomepageView extends GetView<HomepageController> {
  const HomepageView({super.key});

  // Definisi Warna Utama sesuai desain
  final Color _primaryPurple = const Color(0xFF4A148C);
  final Color _secondaryPurple = const Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryPurple, // Background status bar & header
      body: Stack(
        children: [
          // ================= MAIN CONTENT STRUKTUR =================
          Column(
            children: [
              // 1. Header Area (Judul, Profil, Search Bar)
              _buildHeader(),

              // 2. Body Area (Background Putih dengan Lengkungan)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        45,
                      ), // Lengkungan khas di kiri atas
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // 3. Tab Switcher (Pilihan Menu)
                        _buildTabSwitcher(),

                        const SizedBox(height: 16),

                        // 4. List Content (Berubah sesuai Tab yang dipilih)
                        Expanded(
                          child: Obx(() {
                            if (controller.selectedTab.value == 0) {
                              return _buildDiskusiList();
                            } else {
                              return _buildKolaborasiList();
                            }
                          }),
                        ),

                        // Spacer agar list paling bawah tidak tertutup Bottom Nav
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ================= BOTTOM NAVIGATION BAR =================
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavBar()),
        ],
      ),
    );
  }

  // ================= WIDGET BUILDERS =================

  // --- Header Section ---
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            // Baris Atas: Judul & Profil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Home Page',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    // Avatar Profil
                    GestureDetector(
                      onTap: controller.goToProfile,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/150?img=5',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icon Settings
                    GestureDetector(
                      onTap: controller.goToSettings,
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
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Tab Switcher ---
  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _tabButton("Diskusi dan Materi", 0)),
            const SizedBox(width: 12),
            Expanded(child: _tabButton("Catatan Kolaborasi", 1)),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    bool isActive = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.black, // Border hitam sesuai desain
            width: 1,
          ),
          // Jika aktif mungkin bisa dikasih shadow dikit atau style beda
          // Tapi di desain terlihat plain border
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // --- LIST 1: DISKUSI & MATERI ---
  Widget _buildDiskusiList() {
    return Obx(() {
      final items = controller.diskusiList;
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final item = items[index];

          // GestureDetector Utama untuk klik Card -> Buka Detail
          return GestureDetector(
            onTap: () => controller.openDetailMateri(item),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // Gradient Background Card
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, _primaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card (Avatar, Nama, Tombol Ikuti)
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=5',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? 'Materi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Upload Tanggal ${item['date'] ?? ''}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Ikuti',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Judul Materi
                    Text(
                      item['title'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Gambar / Thumbnail Materi
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                            item['image'] ??
                                'https://picsum.photos/seed/note-fallback/400/200',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Footer Actions (Download, Like, Chat)
                    Row(
                      children: [
                        // 1. Tombol Download (Bookmark Icon)
                        GestureDetector(
                          onTap: () => controller.showDownloadDialog(),
                          child: _iconAction(Icons.bookmark_border),
                        ),
                        const SizedBox(width: 8),

                        // 2. Tombol Like
                        _iconAction(Icons.favorite_border),
                        const SizedBox(width: 8),

                        // 3. Tombol Chat
                        GestureDetector(
                          onTap: () => controller.showChatBottomSheet(),
                          child: _iconAction(Icons.comment_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _iconAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.black),
    );
  }

  // --- LIST 2: CATATAN KOLABORASI ---
  Widget _buildKolaborasiList() {
    return Obx(() {
      final items = controller.kolaborasiList;
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          final title = item['title'] ?? 'Tanpa Judul';
          final desc = item['desc'] ?? '';
          final viewers = item['viewers'] ?? '0';
          final time = item['time'] ?? '';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFE1BEE7), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final url = item['link'];
                        if (url is String && url.isNotEmpty) {
                          _launchUrl(url);
                        } else {
                          Get.snackbar('Info', 'Link tidak tersedia');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Buka',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white54, height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 20,
                      child: Stack(
                        children: const [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=1',
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=2',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$viewers Orang sedang melihat',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavBar() {
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
          // Tombol Home Aktif
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 28),
          ),

          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              // Navigasi ke halaman messages (chat)
              Get.toNamed('/chat/rooms');
            },
          ),

          // ============================================
          // UPDATE BAGIAN INI (TOMBOL TAMBAH)
          // ============================================
          GestureDetector(
            onTap: () => controller.showCreateActionDialog(),
            child: Container(
              padding: const EdgeInsets.all(
                4,
              ), // Padding agar border tidak mepet icon
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black54, size: 24),
            ),
          ),

          // ============================================
          IconButton(
            icon: const Icon(
              Icons.mic_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              // Navigasi ke halaman speech
              Get.toNamed('/speech/upload');
            },
          ),
        ],
      ),
    );
  }

  // Util: launch external URL
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Tidak dapat membuka link');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka link: $e');
    }
  }
}

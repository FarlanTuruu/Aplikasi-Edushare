import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_collaboration_controller.dart';

class ListCollaborationView extends GetView<ListCollaborationController> {
  const ListCollaborationView({super.key});

  // Definisi Warna Utama - KONSISTEN dengan create_collaboration_view
  static const Color _primaryPurple = Color(0xFF4A148C);
  static const Color _secondaryPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: _primaryPurple, // Konsisten dengan create
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isTablet),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45), // Konsisten dengan create
                    topRight: Radius.circular(45),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: _primaryPurple),
                      );
                    }
                    if (controller.collaborations.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        top: 30,
                        left: isTablet ? 30 : 20,
                        right: isTablet ? 30 : 20,
                        bottom: 100, // Ruang untuk navbar
                      ),
                      itemCount: controller.collaborations.length,
                      itemBuilder: (context, index) {
                        return _buildCollaborationCard(
                          controller.collaborations[index],
                          index,
                          isTablet,
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar - KONSISTEN dengan create
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // HEADER - Konsisten dengan create
  // ============================================================
  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 40 : 24,
        isTablet ? 20 : 16,
        isTablet ? 40 : 24,
        isTablet ? 20 : 24,
      ),
      child: Row(
        children: [
          // Back Button
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
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              'Catatan Upload',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Profile & Settings
          Row(
            children: [
              GestureDetector(
                onTap: controller.goToProfile,
                child: Container(
                  width: isTablet ? 48 : 40,
                  height: isTablet ? 48 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=5'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              GestureDetector(
                onTap: controller.goToSettings,
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: isTablet ? 32 : 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLLABORATION CARD
  // ============================================================
  Widget _buildCollaborationCard(
    Map<String, dynamic> data,
    int index,
    bool isTablet,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: isTablet ? 100 : 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(
              0xFFE1BEE7,
            ), // Light Purple - konsisten dengan profile card
            _primaryPurple, // Primary Purple
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
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20.0 : 16.0,
          vertical: 12.0,
        ),
        child: Row(
          children: [
            // Date Box
            Container(
              width: isTablet ? 60 : 50,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: isTablet ? 18 : 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    data['day'],
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                data['title'],
                style: TextStyle(
                  fontSize: isTablet ? 17 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Action Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton(
                  'Edit',
                  () => controller.editCollaboration(index),
                  isTablet,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  'Delete',
                  () => controller.deleteCollaboration(index),
                  isTablet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap, bool isTablet) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTablet ? 70 : 60,
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
          style: TextStyle(
            fontSize: isTablet ? 12 : 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION - KONSISTEN dengan create
  // ============================================================
  Widget _buildBottomNavigation() {
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
          // Home Button
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black54, size: 28),
            onPressed: () => Get.toNamed('/homepage'),
          ),

          // Chat Button
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () => Get.toNamed('/chat/rooms'),
          ),

          // Add Button (Active di halaman list juga bisa menampilkan dialog)
          GestureDetector(
            onTap: _showCreateActionDialog,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),

          // Mic Button
          IconButton(
            icon: const Icon(
              Icons.mic_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () => Get.toNamed('/speech/start'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CREATE ACTION DIALOG (KONSISTEN DENGAN CREATE)
  // ============================================================
  void _showCreateActionDialog() {
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

  // ============================================================
  // DIALOG ACTION BUTTON HELPER
  // ============================================================
  Widget _dialogActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
                color: _primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primaryPurple, size: 24),
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

  // ============================================================
  // EMPTY STATE
  // ============================================================
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_notes_controller.dart';
import '../../../../models/note_model.dart';

class ListNotesView extends GetView<ListNotesController> {
  const ListNotesView({super.key});

  // Definisi Warna Utama - Konsisten dengan homepage & list_speech
  static const Color _primaryPurple = Color(0xFF4A148C);
  static const Color _secondaryPurple = Color(0xFF7B1FA2);

  // Helper untuk cek apakah di modul notes
  bool _isInNotesModule() {
    final currentRoute = Get.currentRoute;
    return currentRoute.contains('/notes/');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: _primaryPurple,
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
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  child: Column(
                    children: [
                      GetBuilder<ListNotesController>(
                        builder: (ctrl) => Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          child: _buildSearchBar(isTablet),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                        ),
                        child: _buildNavigationMenu(isTablet),
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildFilterButton(isTablet),
                        ),
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: _primaryPurple,
                              ),
                            );
                          }

                          if (controller.filteredNotesList.isEmpty) {
                            return _buildEmptyState(isTablet);
                          }

                          return _buildNotesList(isTablet);
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
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 40 : 24,
        isTablet ? 20 : 16,
        isTablet ? 40 : 24,
        isTablet ? 20 : 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Note List',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed('/settings/profile'),
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
                onTap: () {},
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

  Widget _buildSearchBar(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: ValueKey('search_${controller.hashCode}'),
              controller: controller.searchController,
              onChanged: (value) => controller.searchNotes(value),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400]),
                onPressed: () => controller.clearSearch(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNavButton('List', true, isTablet, () {}),
          const SizedBox(width: 12),
          _buildNavButton(
            'Draft',
            false,
            isTablet,
            () => Get.toNamed('/notes/draft'),
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            'Archived',
            false,
            isTablet,
            () => Get.toNamed('/notes/archived'),
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            'Scheduled',
            false,
            isTablet,
            () => Get.toNamed('/notes/scheduled'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    String text,
    bool isActive,
    bool isTablet,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 18,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: isTablet ? 14 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(bool isTablet) {
    return GestureDetector(
      onTap: () => controller.showFilterDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 12,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: TextStyle(
                color: Colors.black,
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(bool isTablet) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotes,
      color: _primaryPurple,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: isTablet ? 24 : 20,
          right: isTablet ? 24 : 20,
          top: isTablet ? 16 : 12,
          bottom: 80,
        ),
        itemCount: controller.filteredNotesList.length,
        itemBuilder: (context, index) {
          final note = controller.filteredNotesList[index];
          return _buildNoteCard(note, isTablet);
        },
      ),
    );
  }

  Widget _buildNoteCard(NoteModel note, bool isTablet) {
    return GestureDetector(
      onTap: () => controller.viewNoteDetail(note.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      note.day,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      note.month,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Row(
                  children: [
                    _buildActionButton(
                      'Archive',
                      isTablet,
                      () => controller.archiveNote(note.id),
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildActionButton(
                      'Edit',
                      isTablet,
                      () => controller.editNote(note.id),
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    _buildActionButton(
                      'Delete',
                      isTablet,
                      () => controller.deleteNote(note.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, bool isTablet, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 10,
          vertical: isTablet ? 6 : 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 11 : 10,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: isTablet ? 100 : 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Belum ada catatan',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Tambahkan catatan pertama Anda',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/notes/create'),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Catatan',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION - HIGHLIGHT PERSISTEN
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
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black54, size: 28),
            onPressed: () => Get.toNamed('/homepage'),
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () => Get.toNamed('/chat/rooms'),
          ),
          // Add Button dengan HIGHLIGHT PERSISTEN di modul notes
          GestureDetector(
            onTap: _showCreateActionDialog,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isInNotesModule() ? _primaryPurple : Colors.transparent,
                border: Border.all(
                  color: _isInNotesModule() ? _primaryPurple : Colors.black54,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: _isInNotesModule() ? Colors.white : Colors.black54,
                size: 24,
              ),
            ),
          ),
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
}

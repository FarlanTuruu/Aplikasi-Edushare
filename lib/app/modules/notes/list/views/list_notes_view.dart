import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_notes_controller.dart';
import '../../../../models/note_model.dart';

class ListNotesView extends GetView<ListNotesController> {
  const ListNotesView({super.key});

  // Definisi Warna Utama - Konsisten dengan homepage & list_speech
  static const Color _primaryPurple = Color(0xFF4A148C);
  static const Color _secondaryPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: _primaryPurple, // Konsisten dengan homepage
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
                    topLeft: Radius.circular(45), // Konsisten dengan homepage
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
                      // Search Bar
                      GetBuilder<ListNotesController>(
                        builder: (ctrl) => Padding(
                          padding: EdgeInsets.all(isTablet ? 24 : 20),
                          child: _buildSearchBar(isTablet),
                        ),
                      ),
                      // Navigation Menu
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                        ),
                        child: _buildNavigationMenu(isTablet),
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      // Filter Button
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
                      // Notes List
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
      // Bottom Navigation Bar - Konsisten dengan homepage
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // HEADER
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
                onTap: () {
                  // Navigate to settings
                },
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
  // SEARCH BAR
  // ============================================================
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

  // ============================================================
  // NAVIGATION MENU
  // ============================================================
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
          border: Border.all(
            color: Colors.black, // Konsisten dengan homepage
            width: 1,
          ),
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

  // ============================================================
  // FILTER BUTTON
  // ============================================================
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

  // ============================================================
  // NOTES LIST
  // ============================================================
  Widget _buildNotesList(bool isTablet) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotes,
      color: _primaryPurple,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: isTablet ? 24 : 20,
          right: isTablet ? 24 : 20,
          top: isTablet ? 16 : 12,
          bottom: 80, // Space untuk bottom navbar
        ),
        itemCount: controller.filteredNotesList.length,
        itemBuilder: (context, index) {
          final note = controller.filteredNotesList[index];
          return _buildNoteCard(note, isTablet);
        },
      ),
    );
  }

  // ============================================================
  // NOTE CARD
  // ============================================================
  Widget _buildNoteCard(NoteModel note, bool isTablet) {
    return GestureDetector(
      onTap: () => controller.viewNoteDetail(note.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE1BEE7), // Light Purple
              Color(0xFF4A148C), // Primary Purple
            ],
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
              // Date Box
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

              // Title
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Konsisten dengan homepage card
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // Action Buttons
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

  // ============================================================
  // EMPTY STATE
  // ============================================================
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

  // 🔧 BOTTOM NAVBAR - Konsisten dengan create_notes_view
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
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.black54,
              size: 28,
            ),
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
          GestureDetector(
            onTap: () {
              _showCreateActionDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.mic_outlined,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () => Get.toNamed('/speech/upload'),
          ),
        ],
      ),
    );
  }

  // 🔧 CREATE ACTION DIALOG - Sama dengan create_notes_view
  void _showCreateActionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Materi Or\nCatatan Colaboration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCreateOptionButton(
                    title: 'Materi',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/notes/create');
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildCreateOptionButton(
                    title: 'Catatan',
                    onTap: () {
                      Get.back();
                      Get.toNamed('/collab/create');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOptionButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 100,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const CircleBorder(),
            elevation: 4,
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_notes_controller.dart';
import '../../../../models/note_model.dart';

class ListNotesView extends GetView<ListNotesController> {
  const ListNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF6B2C91),
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
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // 🔧 FIX: Wrap TextField dengan GetBuilder untuk rebuild safety
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
                              color: Color(0xFF6B2C91),
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
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 20,
        vertical: isTablet ? 20 : 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Note List',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 24 : 20,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              InkWell(
                onTap: () => Get.toNamed('/settings/profile'),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        // 🔧 FIX: Tambahkan key unik untuk force rebuild
        key: ValueKey('search_${controller.hashCode}'),
        controller: controller.searchController,
        onChanged: (value) => controller.searchNotes(value),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: isTablet ? 16 : 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: isTablet ? 24 : 20,
          ),
          suffixIcon: Obx(() {
            // Clear button jika ada text
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[400]),
                onPressed: () => controller.clearSearch(),
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationMenu(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNavButton('List', true, isTablet, () {}),
          SizedBox(width: isTablet ? 16 : 12),
          _buildNavButton(
            'Draft',
            false,
            isTablet,
            () => Get.toNamed('/notes/draft'),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          _buildNavButton(
            'Archived',
            false,
            isTablet,
            () => Get.toNamed('/notes/archived'),
          ),
          SizedBox(width: isTablet ? 16 : 12),
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
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6B2C91) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF6B2C91) : Colors.black,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
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
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          'Sort By',
          style: TextStyle(
            color: Colors.black,
            fontSize: isTablet ? 15 : 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(bool isTablet) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotes,
      color: const Color(0xFF6B2C91),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        itemCount: controller.filteredNotesList.length,
        itemBuilder: (context, index) {
          final note = controller.filteredNotesList[index];
          return _buildNoteCard(note, isTablet);
        },
      ),
    );
  }

  // 🔧 FIXED: Tanpa stopPropagation untuk list_notes_view.dart

  Widget _buildNoteCard(NoteModel note, bool isTablet) {
    return GestureDetector(
      // 👇 Tap card untuk buka detail
      onTap: () => controller.viewNoteDetail(note.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8D5F0), Color(0xFF6B2C91)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  border: Border.all(color: Colors.black, width: 1.5),
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
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),

              // 🔑 Wrap tombol-tombol dengan GestureDetector untuk block parent tap
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Empty onTap untuk block parent tap
                child: Row(
                  children: [
                    _buildActionButton(
                      'Archive',
                      isTablet,
                      () => controller.archiveNote(note.id),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildActionButton(
                      'Edit',
                      isTablet,
                      () => controller.editNote(note.id),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
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

  // 🔧 Kembali ke VoidCallback normal
  Widget _buildActionButton(String text, bool isTablet, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 13 : 11,
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
            icon: const Icon(Icons.add),
            label: const Text('Tambah Catatan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2C91),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            Icons.home_outlined,
            false,
            () => Get.toNamed('/homepage'),
          ),
          _buildBottomNavItem(
            Icons.chat_bubble_outline,
            false,
            () => Get.toNamed('/chat/rooms'),
          ),
          _buildBottomNavItem(
            Icons.add_circle,
            true,
            () => Get.toNamed('/notes/create'),
          ),
          _buildBottomNavItem(
            Icons.mic_outlined,
            false,
            () => Get.toNamed('/speech/list'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6B2C91) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.black,
                size: 30,
              ),
            ),
            if (icon == Icons.chat_bubble_outline)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

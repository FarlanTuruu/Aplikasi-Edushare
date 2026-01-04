// File: /lib/app/modules/notes/scheduled/views/scheduled_notes_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scheduled_notes_controller.dart';
import '../../../../models/note_model.dart';

class ScheduledNotesView extends GetView<ScheduledNotesController> {
  const ScheduledNotesView({Key? key}) : super(key: key);

  // 🎨 KONSISTENSI WARNA
  static const Color _primaryPurple = Color(0xFF4A148C);
  static const Color _secondaryPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: _primaryPurple, // 🔧 Updated
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
                    topLeft: Radius.circular(45), // 🔧 Updated
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
                      Padding(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        child: _buildSearchBar(isTablet),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 20,
                        ),
                        child: _buildNavigationMenu(isTablet),
                      ),
                      SizedBox(height: isTablet ? 20 : 16),
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: _primaryPurple, // 🔧 Updated
                              ),
                            );
                          }

                          if (controller.scheduledList.isEmpty) {
                            return _buildEmptyState(isTablet);
                          }

                          return _buildScheduledList(isTablet);
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
      bottomNavigationBar: _buildBottomNavigation(), // 🔧 Updated structure
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
            'Note Scheduled',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 26 : 22, // 🔧 Updated
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed('/settings/profile');
                },
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

  Widget _buildSearchBar(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 1), // 🔧 Added
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // 🔧 NAVIGATION MENU - Konsisten
  Widget _buildNavigationMenu(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _menuButton(
            'List',
            false,
            () => Get.toNamed('/notes/list'),
            isTablet,
          ),
          const SizedBox(width: 12),
          _menuButton(
            'Draft',
            false,
            () => Get.toNamed('/notes/draft'),
            isTablet,
          ),
          const SizedBox(width: 12),
          _menuButton(
            'Archived',
            false,
            () => Get.toNamed('/notes/archived'),
            isTablet,
          ),
          const SizedBox(width: 12),
          _menuButton(
            'Scheduled',
            true, // 🔧 Active state
            () {},
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    String text,
    bool active,
    VoidCallback action,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 18,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledList(bool isTablet) {
    return RefreshIndicator(
      onRefresh: controller.refreshScheduled,
      color: _primaryPurple, // 🔧 Updated
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 16 : 12,
        ),
        itemCount: controller.scheduledList.length,
        itemBuilder: (context, index) {
          final scheduled = controller.scheduledList[index];
          return _buildScheduledCard(scheduled, isTablet);
        },
      ),
    );
  }

  Widget _buildScheduledCard(NoteModel scheduled, bool isTablet) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(
      scheduled.date.year,
      scheduled.date.month,
      scheduled.date.day,
    );
    final isDue = noteDay.isBefore(today) || noteDay.isAtSameMomentAs(today);

    return GestureDetector(
      onTap: () => controller.viewScheduledDetail(scheduled.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)], // 🔧 Updated
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
                  border: Border.all(
                    color: isDue ? Colors.orange : _primaryPurple, // 🔧 Updated
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      scheduled.day,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: isDue
                            ? Colors.orange
                            : _primaryPurple, // 🔧 Updated
                      ),
                    ),
                    Text(
                      scheduled.month,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: isDue ? Colors.orange : _primaryPurple,
                      ),
                    ),
                    if (isDue)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DUE',
                          style: TextStyle(
                            fontSize: isTablet ? 10 : 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDue ? Icons.schedule : Icons.schedule_outlined,
                          size: isTablet ? 18 : 16,
                          color: Colors.black87, // 🔧 Updated
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            scheduled.title,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87, // 🔧 Updated
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scheduled.mataKuliah,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.black54, // 🔧 Updated
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dijadwalkan: ${scheduled.fullDate}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.black45, // 🔧 Updated
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Row(
                  children: [
                    _buildActionButton(
                      'Publish',
                      isTablet,
                      () => controller.publishScheduled(scheduled.id),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildActionButton(
                      'Edit',
                      isTablet,
                      () => controller.editScheduled(scheduled.id),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    _buildActionButton(
                      'Delete',
                      isTablet,
                      () => controller.deleteScheduled(scheduled.id),
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
            Icons.schedule_outlined,
            size: isTablet ? 100 : 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Belum ada jadwal',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Jadwalkan catatan untuk tanggal mendatang',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed('/notes/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Buat Catatan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple, // 🔧 Updated
              foregroundColor: Colors.white,
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

  // 🔧 BOTTOM NAVBAR - Konsisten
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

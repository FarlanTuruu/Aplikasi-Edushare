import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scheduled_notes_controller.dart';
import '../../../../models/note_model.dart';

class ScheduledNotesView extends GetView<ScheduledNotesController> {
  const ScheduledNotesView({Key? key}) : super(key: key);

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

                    // 🔧 Tambahkan Obx untuk reactive UI
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6B2C91),
                            ),
                          );
                        }

                        // 🔧 Check apakah ada scheduled notes
                        if (controller.scheduledList.isEmpty) {
                          return _buildEmptyState(isTablet);
                        }

                        // 🔧 Tampilkan list scheduled
                        return _buildScheduledList(isTablet);
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
            'Note Scheduled',
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

  Widget _buildNavigationMenu(bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNavButton(
            'List',
            false,
            isTablet,
            () => Get.toNamed('/notes/list'),
          ),
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
          _buildNavButton('Scheduled', true, isTablet, () {}),
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

  // 🔧 Widget untuk list scheduled
  Widget _buildScheduledList(bool isTablet) {
    return RefreshIndicator(
      onRefresh: controller.refreshScheduled,
      color: const Color(0xFF6B2C91),
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

  // 🔧 Widget untuk card scheduled
  Widget _buildScheduledCard(NoteModel scheduled, bool isTablet) {
    // Check apakah sudah waktunya
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDay = DateTime(
      scheduled.date.year,
      scheduled.date.month,
      scheduled.date.day,
    );
    final isDue = noteDay.isBefore(today) || noteDay.isAtSameMomentAs(today);

    return GestureDetector(
      // 👇 Tap card untuk buka detail
      onTap: () => controller.viewScheduledDetail(scheduled.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDue
                ? [
                    const Color(0xFFFFE082),
                    const Color(0xFFFFA726),
                  ] // Yellow jika sudah waktunya
                : [
                    const Color(0xFFB3E5FC),
                    const Color(0xFF0277BD),
                  ], // Blue jika masih future
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
              // Date Box with indicator
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDue ? Colors.orange : Colors.blue,
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
                        color: isDue ? Colors.orange : Colors.blue,
                      ),
                    ),
                    Text(
                      scheduled.month,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: isDue ? Colors.orange : Colors.blue,
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

              // Note Title & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDue ? Icons.schedule : Icons.schedule_outlined,
                          size: isTablet ? 18 : 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            scheduled.title,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      scheduled.mataKuliah,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Dijadwalkan: ${scheduled.fullDate}',
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 10,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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

  // Method _buildActionButton tetap sama (sudah benar)
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
          _buildBottomNavItem(Icons.home_outlined, false, () {
            Get.toNamed('/homepage');
          }),
          _buildBottomNavItem(Icons.chat_bubble_outline, false, () {
            Get.toNamed('/chat/rooms');
          }),
          _buildBottomNavItem(Icons.add_circle, true, () {
            Get.toNamed('/notes/create');
          }),
          _buildBottomNavItem(Icons.mic_outlined, false, () {
            Get.toNamed('/speech/list');
          }),
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

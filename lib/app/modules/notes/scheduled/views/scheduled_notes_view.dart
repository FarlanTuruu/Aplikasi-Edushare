// File 7: scheduled_notes_view.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scheduled_notes_controller.dart';

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
                    Expanded(
                      child: Center(
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
                          ],
                        ),
                      ),
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
            color: Colors.black.withOpacity(0.1),
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
          // FIXED: Changed isActive from false to true for Add button
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

// lib/app/modules/settings/profile/views/profile_settings_view.dart

import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import '../controllers/profile_settings_controller.dart';

class ProfileSettingsView extends GetView<ProfileSettingsController> {
  const ProfileSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B2C91),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 20,
                          backgroundImage: _imageProvider(
                            controller.profileImageUrl.value,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {}, // Settings action if needed
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
            ),

            // White Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Profile Picture
                    Obx(
                      () => CircleAvatar(
                        key: ValueKey(controller.imageVersion.value),
                        radius: 60,
                        backgroundImage: _imageProvider(
                          controller.profileImageUrl.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Obx(
                      () => Text(
                        controller.userName.value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Menu Items
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              'Edit Profile',
                              onTap: () =>
                                  Get.toNamed('/settings/edit_profile'),
                            ),
                            const Divider(height: 1),
                            _buildMenuItem(
                              'Save Catatan',
                              onTap: () => Get.toNamed('/settings/save-note'),
                            ),
                            const Divider(height: 1),
                            Obx(
                              () => _buildMenuItemWithValue(
                                'Akun',
                                controller.userEmail.value,
                              ),
                            ),
                            const Divider(height: 1),
                            _buildMenuItemWithValue(
                              'Privasi',
                              'Verification 2 Factor',
                            ),
                            const Divider(height: 1),
                            Obx(
                              () => _buildMenuItemWithValue(
                                'Bahasa',
                                controller.userLanguage.value,
                              ),
                            ),
                            const Divider(height: 1),
                            _buildMenuItem(
                              'Log Out',
                              onTap: controller.logout,
                              isLogout: true,
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  ImageProvider _imageProvider(String path) {
    final p = path.trim();
    if (p.isEmpty) {
      return const NetworkImage('https://i.pravatar.cc/150?img=47');
    }
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return NetworkImage(p);
    }
    if (kIsWeb) {
      return const NetworkImage('https://i.pravatar.cc/150?img=47');
    }
    return FileImage(File(p));
  }

  Widget _buildMenuItem(
    String title, {
    VoidCallback? onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black87,
              ),
            ),
            if (!isLogout) const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithValue(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.home_outlined,
            false,
            () => Get.toNamed('/homepage'),
          ),
          _buildNavItem(
            Icons.chat_bubble_outline,
            false,
            () => Get.toNamed('/chat/rooms'),
          ),
          _buildNavItem(
            Icons.add_circle_outline,
            false,
            () => Get.toNamed('/notes/create'),
          ),
          _buildNavItem(
            Icons.mic_outlined,
            false,
            () => Get.toNamed('/speech/list'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(icon, color: Colors.black, size: 30)),
      ),
    );
  }
}

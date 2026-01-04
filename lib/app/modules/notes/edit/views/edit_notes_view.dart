// File: /lib/app/modules/notes/edit/views/edit_notes_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_notes_controller.dart';

class EditNotesView extends GetView<EditNotesController> {
  const EditNotesView({super.key});

  // Definisi Warna Utama - Konsisten dengan create_notes & homepage
  static const Color _primaryPurple = Color(0xFF4A148C);
  static const Color _secondaryPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: _primaryPurple, // Konsisten dengan create_notes
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
                    topLeft: Radius.circular(
                      45,
                    ), // Konsisten dengan create_notes
                    topRight: Radius.circular(45),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: isTablet ? 30 : 20,
                      right: isTablet ? 30 : 20,
                      bottom: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildNavigationMenu(isTablet),
                        const SizedBox(height: 20),
                        _buildProfileCard(isTablet),
                        const SizedBox(height: 24),
                        _buildForm(isTablet),
                        // Spacer agar form tidak tertutup bottom navbar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar - Konsisten dengan create_notes
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // TOP NAVBAR - Konsisten dengan create_notes
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
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                iconSize: isTablet ? 28 : 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Note',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

  // ============================================================
  // NAVIGATION MENU - Konsisten dengan create_notes
  // ============================================================
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
            false,
            () => Get.toNamed('/notes/scheduled'),
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
          borderRadius: BorderRadius.circular(
            30,
          ), // Konsisten dengan create_notes
          border: Border.all(
            color: Colors.black, // Konsisten dengan create_notes
            width: 1,
          ),
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

  // ============================================================
  // PROFILE CARD - Konsisten dengan create_notes
  // ============================================================
  Widget _buildProfileCard(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 30 : 25,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nanda Adela',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Konsisten dengan create_notes
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.black54, // Konsisten dengan create_notes
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Edit Catatan Atau Materi',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87, // Konsisten dengan create_notes
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM - Konsisten dengan create_notes
  // ============================================================
  Widget _buildForm(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field("Mata Kuliah", controller.mataKuliahController),
        _field("Judul Catatan", controller.judulController),
        _dateField("Tanggal", controller.tanggalController),
        _field("Deskripsi", controller.deskripsiController, maxLines: 4),
        const SizedBox(height: 10),
        _uploadFileSection(),
        const SizedBox(height: 30),
        _actionButtons(),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1), // Konsisten
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: c,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Enter Input",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1), // Konsisten
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: c,
              readOnly: true,
              onTap: controller.selectDate,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Enter Input",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadFileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Unggah File",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1), // Konsisten
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    controller.selectedFileName.value.isEmpty
                        ? "Enter Input"
                        : controller.selectedFileName.value,
                    style: TextStyle(
                      color: controller.selectedFileName.value.isEmpty
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: controller.pickFile,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryPurple, // Konsisten dengan create_notes
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.cancelEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "Batal",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.updateNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple, // Konsisten dengan create_notes
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Simpan Perubahan",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVBAR - Konsisten dengan create_notes & Homepage
  // ============================================================
  Widget _buildBottomNavigation() {
    return Container(
      height: 80, // Konsisten dengan create_notes
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
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.black54,
              size: 28,
            ),
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

          // Add Button
          GestureDetector(
            onTap: () {
              _showCreateActionDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.black54, size: 24),
            ),
          ),

          // Mic Button
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

  // ============================================================
  // CREATE ACTION DIALOG - Sama dengan create_notes
  // ============================================================
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

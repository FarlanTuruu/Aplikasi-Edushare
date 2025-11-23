// ==================== VIEW ====================
// File: create_notes_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/create_notes_controller.dart';

class CreateNotesView extends GetView<CreateNotesController> {
  const CreateNotesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B2C91),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content Card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Tab Bar
                    _buildTabBar(),

                    const SizedBox(height: 30),

                    // Form Container
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D4F0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info
                              _buildUserInfo(),

                              const SizedBox(height: 20),

                              // Title
                              const Text(
                                'Bagikan Catatan Atau Materi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Form Fields
                              _buildFormFields(),

                              const SizedBox(height: 30),

                              // Action Buttons
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bottom Navigation
                    _buildBottomNavigation(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Image.network(
                  'https://via.placeholder.com/40',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.settings, color: Colors.white, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabButton('Draft', 0),
          const SizedBox(width: 12),
          _buildTabButton('Archived', 1),
          const SizedBox(width: 12),
          _buildTabButton('Scheduled', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return Obx(() {
      bool isSelected = controller.selectedTab.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Image.network(
            'https://via.placeholder.com/50',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nanda Adela',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Online',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mata Kuliah
        _buildLabel('Mata Kuliah'),
        _buildTextField(controller.mataKuliahController, 'Enter Input'),

        const SizedBox(height: 16),

        // Judul Catatan
        _buildLabel('Judul Catatan'),
        _buildTextField(controller.judulCatatanController, 'Enter Input'),

        const SizedBox(height: 16),

        // Tanggal
        _buildLabel('Tanggal'),
        _buildTextField(controller.tanggalController, 'Enter Input'),

        const SizedBox(height: 16),

        // Deskripsi
        _buildLabel('Deskripsi'),
        _buildTextField(
          controller.deskripsiController,
          'Enter Input',
          maxLines: 3,
        ),

        const SizedBox(height: 16),

        // Upload File
        _buildFileUpload(),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: textController,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFileUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unggah File',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.selectedFileName.value,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.pickFile,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.upload_file, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton('Batal', false, controller.cancel),
        const SizedBox(width: 12),
        _buildActionButton('Draft', false, controller.saveDraft),
        const SizedBox(width: 12),
        _buildActionButton('Unggah', true, controller.upload),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    bool isUnggah,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isUnggah ? const Color(0xFF6B2C91) : Colors.white,
        foregroundColor: isUnggah ? Colors.white : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(text),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, false),
          _buildNavItem(Icons.chat_bubble_outline, true),
          _buildNavItem(Icons.add_circle, false, isMain: true),
          _buildNavItem(Icons.mic_none, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    bool hasNotification, {
    bool isMain = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMain ? const Color(0xFF6B2C91) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 30,
            color: isMain ? Colors.white : Colors.black,
          ),
        ),
        if (hasNotification)
          Positioned(
            right: 8,
            top: 8,
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
    );
  }
}

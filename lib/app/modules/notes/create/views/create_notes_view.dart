import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_notes_controller.dart';

class CreateNotesView extends GetView<CreateNotesController> {
  const CreateNotesView({super.key});

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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      const Color(0xFFE8D5F0).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
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
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP NAVBAR - 🆕 Dynamic title based on edit mode
  // ============================================================
  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 20,
        vertical: isTablet ? 20 : 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Static title untuk Create
          Text(
            'Add Note',
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
                backgroundColor: Colors.white,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=5',
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              InkWell(
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

  // ============================================================
  // NAVIGATION MENU
  // ============================================================
  Widget _buildNavigationMenu(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _menuButton('List', false, () => Get.toNamed('/notes/list'), isTablet),
        _menuButton(
          'Draft',
          false,
          () => Get.toNamed('/notes/draft'),
          isTablet,
        ),
        _menuButton(
          'Archived',
          false,
          () => Get.toNamed('/notes/archived'),
          isTablet,
        ),
        _menuButton(
          'Scheduled',
          false,
          () => Get.toNamed('/notes/scheduled'),
          isTablet,
        ),
      ],
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
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6B2C91) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: active ? const Color(0xFF6B2C91) : Colors.black,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================
  Widget _buildProfileCard(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D5F0).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 30 : 25,
                backgroundColor: Colors.white,
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Static subtitle untuk Create
          Text(
            'Bagikan Catatan Atau Materi',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM
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
              border: Border.all(color: Colors.black, width: 1.5),
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
              border: Border.all(color: Colors.black, width: 1.5),
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
            border: Border.all(color: Colors.black, width: 1.5),
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
                    color: const Color(0xFF6B2C91),
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

  // 🆕 Dynamic button text based on edit mode
  Widget _actionButtons() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.cancelNote,
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

          // Draft button selalu muncul di Create mode
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.saveAsDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6B2C91),
              side: const BorderSide(color: Colors.black, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Draft",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
          ),
          const SizedBox(width: 8),

          // Upload button dengan text static
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : controller.uploadNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B2C91),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
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
                    "Unggah",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVBAR
  // ============================================================
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
          _bottomItem(
            Icons.home_outlined,
            false,
            () => Get.toNamed('/homepage'),
          ),
          _bottomItem(
            Icons.chat_bubble_outline,
            false,
            () => Get.toNamed('/chat/rooms'),
          ),
          _bottomItem(Icons.add_circle, true, () {}),
          _bottomItem(
            Icons.mic_outlined,
            false,
            () => Get.toNamed('/speech/list'),
          ),
        ],
      ),
    );
  }

  Widget _bottomItem(IconData i, bool active, VoidCallback a) {
    return InkWell(
      onTap: a,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6B2C91) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(i, color: active ? Colors.white : Colors.black, size: 30),
        ),
      ),
    );
  }
}

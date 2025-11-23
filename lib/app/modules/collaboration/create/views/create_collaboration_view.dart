import 'package:appedushare/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_collaboration_controller.dart';

class CreateCollaborationView extends GetView<CreateCollaborationController> {
  const CreateCollaborationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna Utama (Header)
    final Color primaryHeader = const Color(0xFF4A148C);

    return Scaffold(
      backgroundColor:
          primaryHeader, // Background ungu gelap untuk status bar & header
      body: Column(
        children: [
          // ================= 1. HEADER SECTION =================
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Catatan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // Foto Profil
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/150?img=5',
                            ), // Ganti dengan aset Anda
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Icon Settings
                      const Icon(Icons.settings, color: Colors.white, size: 28),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ================= 2. BODY SECTION (Curve + Content) =================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), // Lengkungan khas di kiri atas
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Tombol "List" (Capsule Shape)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            Routes.COLLAB_LIST,
                          ), // Navigasi kembali ke list
                          borderRadius: BorderRadius.circular(30),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: const Text(
                              "List",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= 3. FORM CARD (Gradient Purple) =================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          // Gradient dari ungu muda (atas) ke ungu gelap (bawah) sesuai gambar
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFD1C4E9), // Ungu muda/abu-abu
                              Color(0xFF6A1B9A), // Ungu gelap
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profil User di dalam Card
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=5',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Nanda Adela",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "Online",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            const Center(
                              child: Text(
                                "Bagikan Catatan Kolaborasi",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // --- Input Fields ---
                            _buildLabel("Mata Kuliah"),
                            _buildInputBox(
                              controller.mataKuliahController,
                              "Enter Input",
                            ),

                            _buildLabel("Judul Catatan"),
                            _buildInputBox(
                              controller.judulCatatanController,
                              "Enter Input",
                            ),

                            _buildLabel("Deskripsi"),
                            _buildInputBox(
                              controller.deskripsiController,
                              "Enter Input",
                              maxLines: 3,
                            ),

                            _buildLabel("Link Docs"),
                            _buildInputBox(
                              controller.linkDocsController,
                              "Enter Input",
                            ),

                            const SizedBox(height: 30),

                            // --- Action Buttons (Batal & Upload) ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Tombol Batal
                                ElevatedButton(
                                  onPressed: controller.goBack,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("Batal"),
                                ),
                                const SizedBox(width: 12),
                                // Tombol Upload
                                ElevatedButton(
                                  onPressed: controller.submitCollaboration,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("Upload"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Spasi bawah agar tidak terlalu mepet
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar (Optional - jika ingin tetap ditampilkan)
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(Icons.home_outlined, color: Colors.black54, size: 28),
            const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black54,
              size: 26,
            ),
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Color(0xFF6A1B9A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const Icon(
              Icons.mic_none_outlined,
              color: Colors.black54,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInputBox(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Warna background input putih
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

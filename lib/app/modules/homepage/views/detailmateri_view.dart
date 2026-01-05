// File: /lib/app/modules/homepage/views/detailmateri_view.dart

import 'package:appedushare/app/modules/settings/profile/controllers/profile_settings_controller.dart';
import 'package:appedushare/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import '../../../data/config.dart';
import '../controllers/homepage_controller.dart';

class DetailMateriView extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailMateriView({super.key, required this.data});

  ProfileSettingsController get _profileCtrl {
    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.put(ProfileSettingsController(), permanent: true);
    }
    return Get.find<ProfileSettingsController>();
  }

  // Helper to build avatar image provider from resolved profile URL
  ImageProvider<Object>? _avatarProvider(ProfileSettingsController p) {
    final url = p.profileImageUrl.value;
    if (url.isEmpty) return null;
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = const Color(0xFF4A148C);
    final String title = (data['title'] ?? 'Tanpa Judul').toString();
    final String mataKuliah = (data['mata_kuliah'] ?? '').toString();
    final String description = (data['description'] ?? '').toString();
    final String fileName = (data['file_name'] ?? '').toString();
    final String fullDate = (data['full_date'] ?? '').toString();
    final String? fileUrl = fileName.isNotEmpty
        ? _buildFileUrl(fileName)
        : null;
    final bool isImage =
        fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif') ||
        fileName.toLowerCase().endsWith('.webp');
    final bool isPdf = fileName.toLowerCase().endsWith('.pdf');

    return Scaffold(
      backgroundColor: primaryPurple,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  // Baris Atas: Judul & Profil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Materi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          // Avatar Profil
                          GestureDetector(
                            onTap: () => Get.toNamed(Routes.PROFILE),
                            child: Obx(() {
                              final p = _profileCtrl;
                              final name = p.userName.value;
                              final initial = name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?';
                              final provider = _avatarProvider(p);
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  color: provider == null
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.transparent,
                                ),
                                child: provider != null
                                    ? ClipOval(
                                        child: Image(
                                          image: provider,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          // Icon Settings
                          GestureDetector(
                            onTap: () => Get.toNamed(Routes.PROFILE),
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
                  const SizedBox(height: 20),
                  // Search Bar (Optional - bisa dihapus jika tidak diperlukan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                Get.back(), // Kembali ke homepage untuk search
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari catatan atau kolaborasi...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // White Body with Curve
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Tombol Tab statis
                      Row(
                        children: [
                          _staticTab("Diskusi dan Materi", true),
                          const SizedBox(width: 12),
                          _staticTab("Catatan Kolaborasi", false),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Judul Materi
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mataKuliah.isNotEmpty ? mataKuliah : 'Materi',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (fullDate.isNotEmpty)
                        Text(
                          fullDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Konten Note
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          children: [
                            // Toolbar PDF Mockup
                            Container(
                              color: const Color(0xFF333333),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    mataKuliah.isNotEmpty
                                        ? mataKuliah
                                        : 'Materi',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 10),
                                  if (fileName.isNotEmpty)
                                    GestureDetector(
                                      onTap: () => _openFile(fileUrl),
                                      child: const Icon(
                                        Icons.open_in_new,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.print,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                            // Isi catatan
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    description.isEmpty
                                        ? 'Tidak ada deskripsi'
                                        : description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(height: 12),
                                  if (isImage && fileUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Image.network(
                                        fileUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Text(
                                          'Gagal memuat gambar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  if (isPdf && fileUrl != null)
                                    SizedBox(
                                      height: 400,
                                      child: FutureBuilder<PdfDocument>(
                                        future: _loadPdfDocument(fileUrl),
                                        builder: (context, snap) {
                                          if (snap.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          if (snap.hasError || !snap.hasData) {
                                            return const Center(
                                              child: Text('Gagal memuat PDF'),
                                            );
                                          }
                                          final controller = PdfControllerPinch(
                                            document: Future.value(snap.data!),
                                          );
                                          return PdfViewPinch(
                                            controller: controller,
                                          );
                                        },
                                      ),
                                    ),
                                  if (fileName.isNotEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _openFile(fileUrl),
                                        icon: const Icon(Icons.open_in_new),
                                        label: const Text('Buka File'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar - UPDATED (Konsisten dengan Homepage)
      bottomNavigationBar: Container(
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
            // Tombol Home - Tetap Highlight & Bisa Kembali
            GestureDetector(
              onTap: () => Get.back(), // Kembali ke homepage
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryPurple, // Tetap highlight
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 28),
              ),
            ),

            // Tombol Chat
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black54,
                size: 28,
              ),
              onPressed: () {
                Get.toNamed('/chat/rooms');
              },
            ),

            // Tombol Tambah
            GestureDetector(
              onTap: () {
                if (Get.isRegistered<HomepageController>()) {
                  Get.find<HomepageController>().showCreateActionDialog();
                } else {
                  _showCreateActionDialog(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.black54, size: 24),
              ),
            ),

            // Tombol Voice/Speech
            IconButton(
              icon: const Icon(
                Icons.mic_outlined,
                color: Colors.black54,
                size: 28,
              ),
              onPressed: () {
                Get.toNamed('/speech/start');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _staticTab(String text, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );
  }

  String _buildFileUrl(String fileName) {
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    return '$host/storage/$fileName';
  }

  Future<PdfDocument> _loadPdfDocument(String url) async {
    String? token;
    if (Get.isRegistered<AuthService>()) {
      token = Get.find<AuthService>().getApiToken();
    }
    final headers = <String, String>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/pdf',
    };

    final resp = await http.get(Uri.parse(url), headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }
    final doc = await PdfDocument.openData(resp.bodyBytes);
    return doc;
  }

  Future<void> _openFile(String? fullUrl) async {
    if (fullUrl == null || fullUrl.isEmpty) {
      Get.snackbar('Error', 'Link file tidak tersedia');
      return;
    }
    try {
      final uri = Uri.parse(fullUrl);
      final extLaunched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (extLaunched) return;

      final defLaunched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (defLaunched) return;

      final inAppLaunched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!inAppLaunched) {
        Get.snackbar('Error', 'Tidak dapat membuka file');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka file: $e');
    }
  }

  // Helper method untuk dialog create (fallback)
  void _showCreateActionDialog(BuildContext context) {
    const purple = Color(0xFF4A148C);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Buat Konten Baru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _dialogActionButton(
                icon: Icons.note_add_outlined,
                label: 'Upload Materi',
                onTap: () {
                  Get.back();
                  Get.toNamed('/notes/create');
                },
              ),
              const SizedBox(height: 12),

              _dialogActionButton(
                icon: Icons.upload_file_outlined,
                label: 'Upload Catatan',
                onTap: () {
                  Get.back();
                  Get.toNamed('/collab/create');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const purple = Color(0xFF4A148C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: purple, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

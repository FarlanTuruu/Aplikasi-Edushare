import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart';
import '../../../data/config.dart';

class DetailMateriView extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailMateriView({super.key, required this.data});

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Materi', // Judul Halaman
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=5',
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.settings, color: Colors.white),
                    ],
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Tombol Tab statis (Hanya visual agar mirip desain)
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
                      const SizedBox(height: 80), // Spasi untuk navbar bawah
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Nav (Statis saja untuk detail view)
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF4A148C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home, color: Colors.white),
            ),
            const Icon(Icons.more_horiz, size: 30, color: Colors.black54),
            const Icon(Icons.add_box_outlined, size: 30, color: Colors.black54),
            const Icon(Icons.mic_none, size: 30, color: Colors.black54),
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
    // Include Authorization header if token is set, some storages require it
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
      // Coba external app terlebih dulu
      final extLaunched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (extLaunched) return;

      // Fallback ke mode default platform
      final defLaunched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (defLaunched) return;

      // Fallback terakhir: in-app webview (jika tersedia)
      final inAppLaunched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!inAppLaunched) {
        Get.snackbar('Error', 'Tidak dapat membuka file');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka file: $e');
    }
  }
}

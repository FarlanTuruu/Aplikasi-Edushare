import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailMateriView extends StatelessWidget {
  final Map<String, dynamic> data;
  const DetailMateriView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = const Color(0xFF4A148C);

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
                      const Text(
                        "Software Development Life Cycle (SDLC)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['title'] ??
                            'Catatan Untuk Mata Kuliah Pengembangan Industri 4.0',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),

                      const SizedBox(height: 20),

                      // PDF Viewer Mockup (Gambar Hitam seperti desain)
                      Container(
                        width: double.infinity,
                        // height: 500, // Biarkan height menyesuaikan isi atau set fixed
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
                                  const Text(
                                    "SDLC",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    "1 / 2  -  100%  + ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 18,
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
                            // Konten "Kertas" PDF
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tahukah kamu apa itu metode SDLC? Metode SDLC (Software Development Life Cycle) adalah proses pembuatan dan pengubahan sistem serta model...",
                                    style: TextStyle(fontSize: 10, height: 1.5),
                                    textAlign: TextAlign.justify,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Waterfall",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Diagram Mockup
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Waterfall_model.svg/1200px-Waterfall_model.svg.png',
                                    height: 200,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Metode SDLC yang pertama adalah waterfall. Metode waterfall adalah metode kerja yang menekankan fase-fase yang berurutan dan sistematis.",
                                    style: TextStyle(fontSize: 10, height: 1.5),
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/detailmateri_view.dart'; // Kita akan buat file ini di bawah

class HomepageController extends GetxController {
  final selectedTab = 0.obs;
  final commentController = TextEditingController();

  void changeTab(int index) => selectedTab.value = index;

  // Dummy Data Diskusi

  final diskusiList = [
    {
      'name': 'Alfi Aulia',
      'date': '25 Des',
      'title':
          'Catatan Untuk Mata Kuliah Pengembangan Industri 4.0 Untuk Semester 5',
      'image': 'https://picsum.photos/seed/pdf1/400/200',
    },
    {
      'name': 'Rizky Saputra',
      'date': '24 Des',
      'title': 'Materi Dasar Flutter dan State Management GetX',
      'image': 'https://picsum.photos/seed/pdf2/400/200',
    },
  ];
  final kolaborasiList = [
    {
      'title': 'Rangkuman Lengkap : Matakuliah Rekayasa Interaksi',
      'desc':
          'ini adalah catatan yang kutulis untuk matakuliah RI semoga membantu kalian semuanya dengan catatan yang saya tulis',
      'viewers': '2',
      'time': '3 menit yang lalu',
    },
    {
      'title': 'Rangkuman Lengkap : Matakuliah Rekayasa Kebutuhan',
      'desc':
          'ini adalah catatan yang kutulis untuk matakuliah RK semoga membantu kalian semuanya dengan catatan yang saya tulis',
      'viewers': '5',
      'time': '10 menit yang lalu',
    },
    {
      'title': 'Rangkuman Lengkap : Matakuliah Praskripsi',
      'desc':
          'ini adalah catatan yang kutulis untuk matakuliah Praskripsi semoga membantu kalian semuanya dengan catatan yang saya tulis',
      'viewers': '2',
      'time': '3 menit yang lalu',
    },
    {
      'title': 'Rangkuman Lengkap : Matakuliah MPPL',
      'desc':
          'ini adalah catatan yang kutulis untuk matakuliah MPPL semoga membantu kalian semuanya dengan catatan yang saya tulis',
      'viewers': '2',
      'time': '3 menit yang lalu',
    },
  ];

  // --- FITUR 1: Buka Halaman Detail ---
  void openDetailMateri(Map<String, dynamic> item) {
    Get.to(() => DetailMateriView(data: item));
  }

  // --- FITUR 2: Download Dialog ---
  void showDownloadDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Gradient Ungu sesuai desain download.png
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
                'Note Succesfully\nDownloaded',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Ikon Download Besar
              const Icon(
                Icons.download_rounded,
                size: 100,
                color: Colors.black,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FITUR 3: Chat Bottom Sheet ---
  void showChatBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7, // Tinggi 70% layar
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Garis handle
            Container(width: 50, height: 4, color: Colors.grey[300]),
            const SizedBox(height: 20),

            // List Chat
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildChatBubble("Mantap bang", "10:10"),
                  _buildChatBubble("Catatannya lengkap terimakasih", "10:10"),
                  _buildChatBubble("terimakasih bang mantap", "10:10"),
                  _buildChatBubble("catatannya ada kurang", "10:10"),
                ],
              ),
            ),

            // Input Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.blue[400], size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Input",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true, // Agar bisa full height
    );
  }

  Widget _buildChatBubble(String text, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFCE93D8), // Warna ungu muda chat bubble
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Dummy Navigasi
  void goToProfile() {}
  void goToSettings() {}
}

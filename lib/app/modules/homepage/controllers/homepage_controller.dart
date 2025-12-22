import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../views/detailmateri_view.dart'; // Halaman detail materi/note
import '../../collaboration/list/controllers/list_collaboration_controller.dart';
import '../../../services/notes_service.dart';
import '../../../models/note_model.dart';
import '../../../data/config.dart';

class HomepageController extends GetxController {
  final selectedTab = 0.obs;
  final commentController = TextEditingController();

  void changeTab(int index) => selectedTab.value = index;

  // Dummy Data Diskusi
  // Diganti: daftar diskusi/materi berasal dari NotesService (published/list)
  final diskusiList = <Map<String, String>>[].obs;
  // Kolaborasi di Homepage akan mengambil dari ListCollaborationController
  final kolaborasiList = <Map<String, String>>[].obs;
  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    // Pastikan controller list kolaborasi tersedia
    if (!Get.isRegistered<ListCollaborationController>()) {
      Get.put(ListCollaborationController(), permanent: true);
    }
    final listController = Get.find<ListCollaborationController>();

    // Sinkronkan data kolaborasi ke homepage (map field seperlunya)
    _syncFromCollaborations(listController);

    // Paksa refresh pertama kali agar data terbaru muncul
    listController.loadCollaborations(force: true);

    // Dengarkan perubahan selanjutnya
    ever(listController.collaborations, (_) {
      _syncFromCollaborations(listController);
    });

    // Pastikan NotesService tersedia
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }
    final notesService = Get.find<NotesService>();

    // Load dari server lalu sinkronkan ke homepage
    notesService.refreshAll().then((_) => _syncFromNotes(notesService));
    ever<List<NoteModel>>(
      notesService.allNotes,
      (_) => _syncFromNotes(notesService),
    );

    // Polling ringan untuk auto-refresh (notes & collaboration)
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        await notesService.refreshAll();
        await listController.loadCollaborations(force: true);
      } catch (_) {}
    });
  }

  void _syncFromCollaborations(ListCollaborationController listController) {
    final mapped = listController.collaborations.map<Map<String, String>>((e) {
      final title = (e['title'] ?? '').toString();
      final desc = (e['deskripsi'] ?? '').toString();
      final createdAt = (e['createdAt'] ?? '').toString();
      final link = (e['link'] ?? '').toString();
      return {
        'title': title.isEmpty ? 'Tanpa Judul' : title,
        'desc': desc.isEmpty ? createdAt : desc,
        'viewers': '0',
        'time': createdAt,
        'link': link,
      };
    }).toList();
    kolaborasiList.assignAll(mapped);
  }

  void _syncFromNotes(NotesService service) {
    // Gabungkan catatan publik (list) dengan yang terjadwal agar yang dibuat tampil
    final combined = <NoteModel>[
      ...service.allNotes,
      ...service.scheduledNotes,
    ];
    // Urutkan terbaru dulu
    combined.sort((a, b) => b.date.compareTo(a.date));

    final items = combined.map<Map<String, String>>((note) {
      final dateLabel = _formatDate(note.date);
      // Gunakan file note jika berupa gambar; jika tidak, fallback placeholder
      String imageUrl = 'https://picsum.photos/seed/note-${note.id}/400/200';
      final fn = note.fileName;
      if (fn != null && fn.isNotEmpty) {
        final lower = fn.toLowerCase();
        final isImage =
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.png') ||
            lower.endsWith('.gif') ||
            lower.endsWith('.webp');
        if (isImage) {
          imageUrl = _buildFileUrl(fn);
        }
      }
      return {
        'id': note.id,
        'name': note.mataKuliah.isNotEmpty ? note.mataKuliah : 'Materi',
        'date': dateLabel,
        'title': note.title,
        'image': imageUrl,
        // Tambahan untuk detail
        'description': note.description,
        'mata_kuliah': note.mataKuliah,
        'file_name': note.fileName ?? '',
        'full_date': note.fullDate,
      };
    }).toList();
    diskusiList.assignAll(items);
  }

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

  void showCreateActionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: 320, // Sesuaikan tinggi card
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // Gradient Ungu sesuai desain
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE1BEE7), // Ungu Muda (Kiri Atas)
                Color(0xFF4A148C), // Ungu Gelap (Kanan Bawah)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul Popup
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

              // Row untuk 2 Tombol Bulat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol Materi
                  _buildCreateOptionButton(
                    title: 'Materi',
                    onTap: () {
                      Get.back(); // Tutup dialog dulu
                      // Ganti dengan Route Materi Anda
                      Get.toNamed('/notes/create');
                      print("Pindah ke Create Materi");
                    },
                  ),

                  // Spacer di tengah jika perlu
                  const SizedBox(width: 16),

                  // Tombol Catatan
                  _buildCreateOptionButton(
                    title: 'Catatan',
                    onTap: () {
                      Get.back(); // Tutup dialog dulu
                      // Ganti dengan Route Catatan Anda (misal Create Collaboration yang kemarin)
                      Get.toNamed('/collab/create');
                      print("Pindah ke Create Catatan");
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

  // Helper Widget untuk Tombol Putih Bulat
  Widget _buildCreateOptionButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 100, // Tinggi agar jadi agak bulat/lonjong besar
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: const CircleBorder(), // Membuat tombol benar-benar bulat
            // Jika ingin lonjong (pill shape) ganti CircleBorder dengan:
            // RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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

  // Open docs link in browser
  Future<void> openDocsLink(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Info', 'Link tidak tersedia');
      return;
    }
    // Defer to view layer for calling launcher; keep controller minimal
    // This method can be expanded if you prefer central handling
  }

  String _formatDate(DateTime dt) {
    // dd MMM (contoh: 25 Des). Tanpa locale, bisa jadi Dec.
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final m = months[dt.month - 1];
    final d = dt.day.toString().padLeft(2, '0');
    return '$d $m';
  }

  String _buildFileUrl(String fileName) {
    // Ambil base tanpa /api dan bangun url storage
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    return '$host/storage/$fileName';
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.onClose();
  }
}

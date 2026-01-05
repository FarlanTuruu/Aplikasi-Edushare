import 'package:appedushare/app/modules/settings/profile/controllers/profile_settings_controller.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../views/detailmateri_view.dart'; // Halaman detail materi/note
import '../../collaboration/list/controllers/list_collaboration_controller.dart';
import '../../../services/notes_service.dart';
import '../../../services/follow_service.dart';
import '../../../services/messages_service.dart';
import '../../../models/note_model.dart';
import '../../../data/config.dart';
import 'package:open_file/open_file.dart';
import '../../../services/download_service.dart';

class HomepageController extends GetxController {
  final selectedTab = 0.obs;
  final commentController = TextEditingController();
  final searchQuery = ''.obs;
  final TextEditingController searchTextController = TextEditingController();

  void changeTab(int index) => selectedTab.value = index;

  // Diganti: daftar diskusi/materi berasal dari NotesService (published/list)
  final diskusiList = <Map<String, String>>[].obs;
  // Kolaborasi di Homepage akan mengambil dari ListCollaborationController
  final kolaborasiList = <Map<String, String>>[].obs;
  // Sumber data asli sebelum difilter
  final List<Map<String, String>> _allDiskusi = [];
  final List<Map<String, String>> _allKolaborasi = [];
  Timer? _pollTimer;

  late final ProfileSettingsController profileCtrl;
  final RxSet<String> savedNoteIds = <String>{}.obs;

  // Dapatkan DownloadService
  DownloadService get _downloadService {
    if (!Get.isRegistered<DownloadService>()) {
      Get.put(DownloadService(), permanent: true);
    }
    return Get.find<DownloadService>();
  }

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<ProfileSettingsController>()) {
      Get.put(ProfileSettingsController(), permanent: true);
    }
    profileCtrl = Get.find<ProfileSettingsController>();
    // Panggil loadUserData agar saat masuk homepage, data/gambar terbaru diambil
    profileCtrl.loadUserData();

    // Pastikan controller list kolaborasi tersedia
    if (!Get.isRegistered<ListCollaborationController>()) {
      Get.put(ListCollaborationController(), permanent: true);
    }
    final listController = Get.find<ListCollaborationController>();

    // Sinkronkan data kolaborasi ke homepage (map field seperlunya)
    _syncFromCollaborations(listController);

    // Paksa refresh pertama kali dari public feed
    listController.loadCollaborationsPublic(force: true);

    // Dengarkan perubahan selanjutnya
    ever(listController.collaborations, (_) {
      _syncFromCollaborations(listController);
    });

    // Pastikan NotesService tersedia
    if (!Get.isRegistered<NotesService>()) {
      Get.put(NotesService(), permanent: true);
    }
    final notesService = Get.find<NotesService>();

    // Pastikan FollowService & MessagesService tersedia
    if (!Get.isRegistered<FollowService>()) {
      Get.putAsync<FollowService>(() async => (FollowService()).init());
    }
    if (!Get.isRegistered<MessagesService>()) {
      Get.putAsync<MessagesService>(() async => (MessagesService()).init());
    }

    // Load public feed so all accounts see published notes
    notesService.loadPublicFeed().then((_) => _syncFromNotes(notesService));
    ever<List<NoteModel>>(
      notesService.allNotes,
      (_) => _syncFromNotes(notesService),
    );

    // Load saved notes and keep a reactive set of saved IDs
    notesService.loadAllFromServer().then((_) {
      _syncSavedIds(notesService);
    });
    ever(notesService.savedNotes, (_) => _syncSavedIds(notesService));

    // Polling ringan untuk auto-refresh (notes & collaboration)
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      try {
        await notesService.loadPublicFeed();
        await listController.loadCollaborationsPublic(force: true);
      } catch (_) {}
    });
  }

  void _syncSavedIds(NotesService service) {
    final ids = service.savedNotes.map((e) => e.id).toSet();
    savedNoteIds
      ..clear()
      ..addAll(ids);
    savedNoteIds.refresh();
  }

  void _syncFromCollaborations(ListCollaborationController listController) {
    final mapped = listController.collaborations.map<Map<String, String>>((e) {
      final title = (e['title'] ?? '').toString();
      final desc = (e['deskripsi'] ?? '').toString();
      final createdAt = (e['createdAt'] ?? '').toString();
      final link = (e['link'] ?? '').toString();
      final viewers = (e['viewers'] ?? '0').toString();
      final viewer1 = (e['viewer1'] ?? '').toString();
      final viewer2 = (e['viewer2'] ?? '').toString();
      return {
        'title': title.isEmpty ? 'Tanpa Judul' : title,
        'desc': desc.isEmpty ? createdAt : desc,
        'viewers': viewers,
        'time': createdAt,
        'link': link,
        // top-2 viewer avatars (URL)
        'viewer1': viewer1,
        'viewer2': viewer2,
      };
    }).toList();
    _allKolaborasi
      ..clear()
      ..addAll(mapped);
    _applyFilters();
  }

  bool isNoteSaved(String? id) {
    if (id == null || id.isEmpty) return false;
    return savedNoteIds.contains(id);
  }

  Future<void> toggleSave(Map<String, String> item) async {
    final id = item['id'];
    if (id == null || id.isEmpty) {
      Get.snackbar('Error', 'ID catatan tidak ditemukan');
      return;
    }
    try {
      final notesService = Get.find<NotesService>();
      if (isNoteSaved(id)) {
        await notesService.unsaveNote(id);
        savedNoteIds.remove(id);
        savedNoteIds.refresh();
        Get.snackbar('Berhasil', 'Dihapus dari tersimpan');
      } else {
        await notesService.saveNote(id);
        savedNoteIds.add(id);
        savedNoteIds.refresh();
        Get.snackbar('Berhasil', 'Catatan tersimpan');
      }
      // Optional: refresh SaveNotes module if already active
      try {
        final saveNotesCtrl = Get.find<dynamic>(
          tag: 'SaveNotesController',
        ); // may not exist; ignore failures
        // No-op; retained for potential future integration
      } catch (_) {}
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status simpan: ${e.toString()}');
    }
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
      // Tentukan avatar author: gunakan dari payload publik jika tersedia.
      String authorImage = '';
      if (note.authorImage != null && note.authorImage!.isNotEmpty) {
        authorImage = _resolveImageUrl(note.authorImage!);
      } else {
        // Fallback: jika note milik user saat ini, pakai foto profilnya
        final meId = profileCtrl.userId.value;
        if (note.authorId != null && meId != null && note.authorId == meId) {
          authorImage = profileCtrl.profileImageUrl.value;
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
        // User target untuk follow
        'author_id': (note.authorId?.toString() ?? ''),
        // Avatar author publik bila tersedia (tetap tampil setelah logout)
        'author_image': authorImage,
        // Nama author jika tersedia
        'author_name': note.authorName ?? '',
      };
    }).toList();
    _allDiskusi
      ..clear()
      ..addAll(items);
    _applyFilters();
  }

  // Resolve absolute URL for public images similar to profile resolver
  String _resolveImageUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http')) return raw;
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    if (raw.startsWith('/')) return host + raw;
    if (raw.startsWith('storage/')) return '$host/$raw';
    return '$host/$raw';
  }

  // --- FITUR 1: Buka Halaman Detail ---
  void openDetailMateri(Map<String, dynamic> item) {
    Get.to(() => DetailMateriView(data: item));
  }

  // --- Search Handling ---
  void setSearchQuery(String q) {
    searchQuery.value = q;
    _applyFilters();
  }

  void clearSearch() {
    searchTextController.clear();
    setSearchQuery('');
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    bool contains(String? v) => (v ?? '').toLowerCase().contains(q);

    if (q.isEmpty) {
      diskusiList.assignAll(_allDiskusi);
      kolaborasiList.assignAll(_allKolaborasi);
      return;
    }

    final filteredDiskusi = _allDiskusi.where((m) {
      return contains(m['title']) ||
          contains(m['name']) ||
          contains(m['description']) ||
          contains(m['mata_kuliah']) ||
          contains(m['author_name']);
    }).toList();

    final filteredKolab = _allKolaborasi.where((m) {
      return contains(m['title']) || contains(m['desc']) || contains(m['link']);
    }).toList();

    diskusiList.assignAll(filteredDiskusi);
    kolaborasiList.assignAll(filteredKolab);
  }

  // Increment viewers and update avatar list locally when user opens collaboration
  void bumpCollabViewers(Map<String, String> item) {
    try {
      final link = item['link'] ?? '';
      final idx = _allKolaborasi.indexWhere((m) => m['link'] == link);
      if (idx == -1) return;

      final cur = Map<String, String>.from(_allKolaborasi[idx]);
      final currentCount = int.tryParse(cur['viewers'] ?? '0') ?? 0;
      cur['viewers'] = (currentCount + 1).toString();

      // Put current user's avatar to the first slot, shift previous to second
      final meAvatar = profileCtrl.profileImageUrl.value;
      final prevFirst = cur['viewer1'] ?? '';
      cur['viewer1'] = meAvatar;
      cur['viewer2'] = prevFirst.isNotEmpty
          ? prevFirst
          : (cur['viewer2'] ?? '');

      _allKolaborasi[idx] = cur;
      _applyFilters();
    } catch (_) {}
  }

  // --- FITUR: Follow Author & create chat room ---
  Future<void> followAuthorOf(Map<String, String> item) async {
    final idStr = item['author_id'];
    final userId = idStr != null && idStr.isNotEmpty
        ? int.tryParse(idStr)
        : null;
    if (userId == null) {
      Get.snackbar('Error', 'Tidak menemukan author untuk item ini');
      return;
    }
    try {
      final followService = Get.find<FollowService>();
      final ok = await followService.follow(userId, createChatRoom: false);
      if (ok) {
        // Optional: navigate to chat rooms
        // Get.toNamed('/chat/rooms');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal follow: ${e.toString()}');
    }
  }

  // Method lama untuk backward compatibility
  void showDownloadDialog() {
    Get.snackbar(
      'Info',
      'Gunakan tombol download pada kartu catatan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void showCreateActionDialog() {
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
              const SizedBox(height: 12),
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
  void goToProfile() {
    Get.toNamed('/settings/profile');
  }

  void goToSettings() {
    Get.toNamed('/settings/profile');
  }

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

  // Download file dari catatan
  Future<void> downloadNoteFile(Map<String, String> item) async {
    final fileName = item['file_name'];
    final noteId = item['id'];
    final noteTitle = item['title'] ?? 'Catatan';

    if (fileName == null || fileName.isEmpty) {
      Get.snackbar(
        'Info',
        'Catatan ini tidak memiliki file untuk diunduh',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Check apakah file sudah didownload sebelumnya
      final existingPath = await _downloadService.getDownloadedFilePath(
        fileName,
      );

      if (existingPath != null) {
        // File sudah ada, tanya user mau download ulang atau buka
        _showFileExistsDialog(existingPath, fileName, noteId, noteTitle);
        return;
      }

      // Show progress dialog
      _showDownloadProgressDialog(noteTitle);

      // Download file
      final filePath = await _downloadService.downloadFile(
        fileName,
        onProgress: (received, total) {
          // Progress otomatis update lewat observable di DownloadService
        },
      );

      // Close progress dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (filePath != null) {
        _showDownloadSuccessDialog(fileName, filePath, noteTitle);
      }
    } catch (e) {
      // Close progress dialog jika error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      String errorMessage = 'Gagal mengunduh file';

      if (e.toString().contains('permission')) {
        errorMessage = 'Izin storage diperlukan untuk download';
      } else if (e.toString().contains('tidak ditemukan')) {
        errorMessage = 'File tidak ditemukan di server';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Download timeout - coba lagi';
      }

      Get.snackbar(
        'Error Download',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Dialog jika file sudah ada
  void _showFileExistsDialog(
    String existingPath,
    String fileName,
    String? noteId,
    String noteTitle,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'File Sudah Ada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'File "$fileName" sudah pernah diunduh.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        // Download ulang
                        _redownloadFile(fileName, noteTitle);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Download Ulang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _openFile(existingPath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A148C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Buka File',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Re-download file
  Future<void> _redownloadFile(String fileName, String noteTitle) async {
    try {
      // Hapus file lama
      await _downloadService.deleteDownloadedFile(fileName);

      // Show progress dialog
      _showDownloadProgressDialog(noteTitle);

      // Download ulang
      final filePath = await _downloadService.downloadFile(fileName);

      // Close progress dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (filePath != null) {
        _showDownloadSuccessDialog(fileName, filePath, noteTitle);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Gagal mengunduh ulang: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Show progress dialog saat download
  void _showDownloadProgressDialog(String noteTitle) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.download_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mengunduh "$noteTitle"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  final progress = _downloadService.downloadProgress.value;
                  return Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Dialog sukses download
  void _showDownloadSuccessDialog(
    String fileName,
    String filePath,
    String noteTitle,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFE1BEE7), Color(0xFF4A148C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Download Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                fileName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              FutureBuilder<int?>(
                future: _downloadService.getFileSize(fileName),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final size = _downloadService.formatFileSize(
                      snapshot.data!,
                    );
                    return Text(
                      'Ukuran: $size',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Lokasi: Download',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _openFile(filePath);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A148C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Buka File',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Buka file yang sudah didownload
  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done) {
        Get.snackbar(
          'Info',
          'Tidak dapat membuka file. Silakan buka manual di folder Download',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    searchTextController.dispose();
    super.onClose();
  }
}

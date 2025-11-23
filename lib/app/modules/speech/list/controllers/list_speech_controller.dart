import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListSpeechController extends GetxController {
  final searchController = TextEditingController();

  /// Mode tampilan: false = List, true = Trash
  final isTrashMode = false.obs;
  final searchQuery = ''.obs;

  /// Dropdown filter
  final RxBool isDropdownOpen = false.obs;
  final RxString selectedFilter = 'All (42)'.obs;

  final List<String> filterOptions = [
    'All (42)',
    'Uncategorized (30)',
    'Speech to Teks (3)',
  ];

  /// Data rekaman
  final recordings = <Recording>[
    Recording(title: "Recording 7", time: "25 June 2021 – 08:43 pm"),
    Recording(title: "Recording 6", time: "23 June 2021 – 04:32 am"),
    Recording(title: "Recording 5", time: "18 June 2021 – 11:20 am"),
    Recording(title: "Recording 4", time: "17 June 2021 – 09:14 am"),
    Recording(title: "Recording 3", time: "15 June 2021 – 07:45 pm"),
    Recording(title: "Recording 2", time: "14 June 2021 – 05:12 pm"),
    Recording(title: "Recording 1", time: "10 June 2021 – 01:20 pm"),
  ].obs;

  /// Filter data berdasarkan search dan mode list/trash
  List<Recording> get filteredRecordings {
    final q = searchQuery.value.toLowerCase();

    // Ambil hanya item sesuai mode list/trash
    final list =
        recordings.where((r) => r.isTrash == isTrashMode.value).toList();

    // Jika ada query pencarian
    if (q.isNotEmpty) {
      return list.where((r) => r.title.toLowerCase().contains(q)).toList();
    }

    // Jika ada filter dropdown selain “All”
    if (selectedFilter.value != 'All (42)') {
      return list.where((r) => r.category == selectedFilter.value).toList();
    }

    return list;
  }

  /// Handler pencarian teks
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  /// Ganti mode antara List dan Trash
  void setListMode(bool trash) {
    isTrashMode.value = trash;
  }

  /// Buka/tutup dropdown filter
  void toggleDropdown() {
    isDropdownOpen.value = !isDropdownOpen.value;
  }

  /// Pilih filter dropdown
  void selectFilter(String value) {
    selectedFilter.value = value;
    isDropdownOpen.value = false;
  }

  /// Pindahkan rekaman ke Trash
  void moveToTrash(Recording rec) {
    final idx = recordings.indexOf(rec);
    if (idx != -1) {
      recordings[idx] = rec.copyWith(isTrash: true);
      recordings.refresh();
    }
  }

  /// Hapus permanen dari Trash
  void deletePermanently(Recording rec) {
    recordings.remove(rec);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

/// ===== Model Data Recording =====
class Recording {
  final String title;
  final String time;
  final bool isTrash;
  final String category;

  Recording({
    required this.title,
    required this.time,
    this.isTrash = false,
    this.category = 'Uncategorized (30)',
  });

  Recording copyWith({
    String? title,
    String? time,
    bool? isTrash,
    String? category,
  }) {
    return Recording(
      title: title ?? this.title,
      time: time ?? this.time,
      isTrash: isTrash ?? this.isTrash,
      category: category ?? this.category,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/list_speech_controller.dart';
import '../../trash/controllers/trash_speech_controller.dart';
import '../../trash/views/trash_speech_view.dart';

class ListSpeechView extends GetView<ListSpeechController> {
  const ListSpeechView({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF4A1F7A);

    return Scaffold(
      backgroundColor: purple,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Speech To Teks",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Row(
                    children: const [
                      CircleAvatar(radius: 20),
                      SizedBox(width: 8),
                      Icon(Icons.settings, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // BODY
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F4FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.onSearchChanged,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search",
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // LIST / TRASH BUTTON
                      Row(
                        children: [
                          _pillButton(
                            "List",
                            isActive: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _pillButton(
                            "Trash",
                            isActive: false,
                            onTap: () {
                              Get.put(TrashSpeechController());
                              Get.to(() => const TrashSpeechView());
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FILTER DROPDOWN
                      Obx(() => GestureDetector(
                            onTap: controller.toggleDropdown,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          controller.selectedFilter.value),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                                if (controller.isDropdownOpen.value)
                                  Container(
                                    margin:
                                        const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: controller.filterOptions
                                          .map((opt) {
                                        return GestureDetector(
                                          onTap: () =>
                                              controller.selectFilter(opt),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 12),
                                            child: Text(
                                              opt,
                                              style: const TextStyle(
                                                  fontSize: 14),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),

                      // LIST RECORDINGS
                      Expanded(
                        child: Obx(() {
                          final items =
                              controller.filteredRecordings;
                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                "No recordings found.",
                                style:
                                    TextStyle(color: Colors.grey),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final rec = items[index];
                              return _recordingCard(
                                context: context,
                                recording: rec,
                                purple: purple,
                                controller: controller,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              Icons.home_outlined,
              false,
              () => Get.toNamed('/homepage'),
            ),
            _buildBottomNavItem(
              Icons.chat_bubble_outline,
              false,
              () => Get.toNamed('/chat/rooms'),
            ),
            _buildBottomNavItem(
              Icons.add_circle,
              false,
              () => Get.toNamed('/notes/create'),
            ),
            _buildBottomNavItem(
              Icons.mic_outlined,
              true,
              () => Get.toNamed('/speech/start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      IconData icon, bool isCenter, VoidCallback onTap) {
    const purple = Color(0xFF4A1F7A);

    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: purple,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      );
    }

    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.black),
      onPressed: onTap,
    );
  }

  Widget _pillButton(String label,
      {required bool isActive, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _recordingCard({
    required BuildContext context,
    required Recording recording,
    required Color purple,
    required ListSpeechController controller,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: purple,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.play_arrow, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recording.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  recording.time,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog(
                  context, controller, recording, purple);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ListSpeechController controller,
    Recording rec,
    Color purple,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9D84C8), Color(0xFF4A1F7A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding:
              const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure to\nDELETE this voice?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roundedButton(
                    "No",
                    Colors.white,
                    purple,
                    () => Get.back(),
                  ),
                  _roundedButton(
                    "Yes",
                    purple,
                    Colors.white,
                    () {
                      Get.back();
                      controller.moveToTrash(rec);
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

  Widget _roundedButton(
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
            color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

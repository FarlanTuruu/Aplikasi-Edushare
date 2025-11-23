import 'package:appedushare/app/modules/speech/trash/controllers/trash_speech_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/list_speech_controller.dart';
import '../../trash/views/trash_speech_view.dart';
import '../../trash/bindings/trash_speech_binding.dart';

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
            // 🔹 HEADER
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

            // 🔹 BODY PUTIH
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
                      // 🔹 SEARCH BOX
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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

                      // 🔹 Tombol List / Trash
                      Row(
                        children: [
                          _pillButton(
                            "List",
                            isActive: true,
                            onTap: () {}, // tetap di halaman ini
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

                      // 🔹 DROPDOWN FILTER
                      Obx(() => GestureDetector(
                            onTap: () => controller.toggleDropdown(),
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
                                      Text(controller.selectedFilter.value),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                                if (controller.isDropdownOpen.value)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          controller.filterOptions.map((opt) {
                                        return GestureDetector(
                                          onTap: () {
                                            controller.selectFilter(opt);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 12),
                                            child: Text(opt,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),

                      // 🔹 LIST RECORDING
                      Expanded(
                        child: Obx(() {
                          final items = controller.filteredRecordings;
                          if (items.isEmpty) {
                            return const Center(
                                child: Text("No recordings found.",
                                    style: TextStyle(color: Colors.grey)));
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

      // 🔹 Bottom Nav
      bottomNavigationBar: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.home, size: 32),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_outlined, size: 32),
                Positioned(
                  right: -1,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    
                  ),
                ),
              ],
            ),
            const Icon(Icons.add_circle_outline, size: 38),
            CircleAvatar(
              radius: 22,
              backgroundColor: purple,
              child: const Icon(Icons.mic, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Tombol List / Trash
  Widget _pillButton(String label,
      {required bool isActive, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  // 🔹 Kartu Recording dengan pop-up delete
  Widget _recordingCard({
    required BuildContext context,
    required Recording recording,
    required Color purple,
    required ListSpeechController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recording.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  recording.time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog(context, controller, recording, purple);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  /// 🔸 Pop-up konfirmasi delete
  void _showDeleteDialog(BuildContext context, ListSpeechController controller,
      Recording rec, Color purple) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF9D84C8), Color(0xFF4A1F7A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure to\nDELETE this voice?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roundedButton("No", Colors.white, purple, () {
                    Get.back();
                  }),
                  _roundedButton("Yes", purple, Colors.white, () {
                    Get.back();
                    controller.moveToTrash(rec);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔸 Tombol bulat Yes / No
  Widget _roundedButton(
      String label, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label,
          style:
              TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}

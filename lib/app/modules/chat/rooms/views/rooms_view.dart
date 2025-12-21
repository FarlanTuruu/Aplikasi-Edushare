import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';
import '../../messages/controllers/messages_controller.dart';
import '../../messages/views/messages_view.dart';

class RoomsView extends GetView<RoomsController> {
  const RoomsView({super.key});

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
                children: const [
                  Text(
                    "Chat",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // 🔸 Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: TextField(
                          onChanged: controller.onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔸 Daftar Chat
                      Expanded(
                        child: Obx(() {
                          final rooms = controller.filteredRooms;
                          return ListView.builder(
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return _chatTile(room);
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

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.home_outlined, size: 32),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: purple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            const Icon(Icons.add_circle_outline, size: 38),
            const Icon(Icons.mic_none, size: 32),
          ],
        ),
      ),
    );
  }

  // 🔹 Chat Item dengan Navigasi ke MessagesView
  Widget _chatTile(Map<String, dynamic> room) {
    // room: {id, name, avatar, ...}
    return ListTile(
      leading: (room['avatar'] != null && room['avatar'].toString().isNotEmpty)
          ? CircleAvatar(backgroundImage: NetworkImage(room['avatar']))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(
        room['name']?.toString() ?? '-',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        room['status']?.toString() ?? '',
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        Get.put(MessagesController());
        Get.to(
          () => const MessagesView(),
          arguments: {
            'roomId': room['id'],
            'contactName': room['name'],
            'avatar': room['avatar'],
          },
        );
      },
    );
  }
}

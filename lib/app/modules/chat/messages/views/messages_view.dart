import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/messages_controller.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final contact = Get.arguments ?? {};
    final contactName = contact['contactName'] ?? 'Nanda Adela';
    final avatar = contact['avatar'] ?? 'assets/avatar.png';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => controller.isFollowing.isFalse
                ? IconButton(
                    tooltip: 'Follow user',
                    icon: const Icon(Icons.person_add, color: Colors.black),
                    onPressed: () => controller.followPeer(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(avatar)),
            const SizedBox(width: 10),
            Text(contactName, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),

      // 🔹 Body tanpa background image, full putih
      body: Column(
        children: [
          // Daftar pesan
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              final loading = controller.isLoading.value;
              if (loading && msgs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),

          // Kolom input pesan
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.black54),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: controller.textEditingController,
                      onChanged: (text) =>
                          controller.textController.value = text,
                      onSubmitted: (text) => controller.sendMessage(text),
                      decoration: const InputDecoration(
                        hintText: "Message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      controller.sendMessage(controller.textController.value),
                  icon: const Icon(Icons.send, color: Color(0xFF4A1F7A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Widget balon pesan
  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool fromMe = msg['fromMe'] ?? false;
    final bool unsent = msg['unsent'] ?? false;
    final Color myBlue = const Color(0xFF1E40AF);

    final bubble = Align(
      alignment: fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: fromMe
              ? (unsent ? myBlue.withOpacity(0.6) : myBlue)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromMe ? 16 : 0),
            bottomRight: Radius.circular(fromMe ? 0 : 16),
          ),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(
            color: fromMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );

    if (unsent && fromMe) {
      return Column(
        crossAxisAlignment: fromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          bubble,
          const SizedBox(height: 2),
          const Text(
            'Follow to send',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      );
    }
    return bubble;
  }
}

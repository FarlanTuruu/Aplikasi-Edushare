import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/messages_controller.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final contact = Get.arguments ?? {};
    final contactName = contact['contactName'] ?? 'User';
    final avatar = contact['avatar'];
    const purple = Color(0xFF4A148C);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(contactName, avatar, purple),
      body: Column(
        children: [
          // Daftar pesan dengan animasi
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              final loading = controller.isLoading.value;

              if (loading && msgs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: purple),
                      const SizedBox(height: 16),
                      Text(
                        'Loading messages...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              if (msgs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                reverse: false,
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final msg = msgs[index];
                  final prevMsg = index > 0 ? msgs[index - 1] : null;
                  final showAvatar = _shouldShowAvatar(msg, prevMsg);
                  final showTimestamp = _shouldShowTimestamp(msg, prevMsg);

                  return _buildMessageBubble(
                    msg,
                    showAvatar: showAvatar,
                    showTimestamp: showTimestamp,
                  );
                },
              );
            }),
          ),

          // Input pesan dengan animasi dan shadow
          _buildMessageInput(purple),

          // Emoji Picker
          Obx(() {
            if (controller.showEmojiPicker.value) {
              return SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    controller.onEmojiSelected(emoji);
                  },
                  config: const Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 32,
                      backgroundColor: Color(0xFFF5F5F5),
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: Color(0xFFF5F5F5),
                    ),
                    bottomActionBarConfig: BottomActionBarConfig(
                      backgroundColor: Color(0xFFF5F5F5),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // AppBar yang lebih modern
  PreferredSizeWidget _buildAppBar(String name, dynamic avatar, Color purple) {
    return AppBar(
      elevation: 0,
      backgroundColor: purple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Hero(tag: 'avatar_$name', child: _contactAvatar(avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Active now',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Obx(
          () => controller.isFollowing.isFalse
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => controller.followPeer(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.person_add,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            _showOptionsMenu();
          },
        ),
      ],
    );
  }

  // Widget balon pesan yang lebih modern dengan shadow dan animasi
  Widget _buildMessageBubble(
    Map<String, dynamic> msg, {
    required bool showAvatar,
    required bool showTimestamp,
  }) {
    final bool fromMe = msg['fromMe'] ?? false;
    final bool unsent = msg['unsent'] ?? false;
    final String text = msg['text'] ?? '';
    const purple = Color(0xFF4A148C);

    final bubble = Container(
      margin: EdgeInsets.only(
        top: showTimestamp ? 16 : 2,
        bottom: 2,
        left: fromMe ? 48 : 0,
        right: fromMe ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment: fromMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Timestamp separator
          if (showTimestamp) _buildTimestampSeparator(msg['time']),

          // Message bubble
          Row(
            mainAxisAlignment: fromMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar untuk pesan dari lawan bicara
              if (!fromMe && showAvatar) ...[
                _buildMessageAvatar(msg['avatar']),
                const SizedBox(width: 8),
              ] else if (!fromMe && !showAvatar) ...[
                const SizedBox(width: 40),
              ],

              // Bubble container
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    color: fromMe
                        ? (unsent ? purple.withOpacity(0.6) : purple)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(fromMe ? 20 : 4),
                      bottomRight: Radius.circular(fromMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: fromMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (fromMe && !unsent) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _formatMessageTime(msg['time']),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Unsent message indicator
          if (unsent && fromMe) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.error_outline, size: 14, color: Colors.red[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Follow required to send',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return bubble;
  }

  // Avatar untuk message bubble
  Widget _buildMessageAvatar(String? avatarUrl) {
    final provider = _avatarProviderFromUrl(avatarUrl);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[200]!, width: 2),
        color: Colors.grey[100],
      ),
      child: ClipOval(
        child: provider != null
            ? Image(image: provider, width: 32, height: 32, fit: BoxFit.cover)
            : Icon(Icons.person, size: 18, color: Colors.grey[400]),
      ),
    );
  }

  // Timestamp separator
  Widget _buildTimestampSeparator(String? time) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatTimestamp(time),
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Input pesan yang lebih modern
  Widget _buildMessageInput(Color purple) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              decoration: BoxDecoration(
                color: purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  _showAttachmentOptions();
                },
                icon: Icon(Icons.add, color: purple, size: 24),
                splashRadius: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.textEditingController,
                        onChanged: (text) {
                          controller.textController.value = text;
                          // Hide emoji picker when typing
                          if (text.isNotEmpty &&
                              controller.showEmojiPicker.value) {
                            controller.showEmojiPicker.value = false;
                          }
                        },
                        onTap: () {
                          // Hide emoji picker when tapping text field
                          if (controller.showEmojiPicker.value) {
                            controller.showEmojiPicker.value = false;
                          }
                        },
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            controller.sendMessage(text);
                          }
                        },
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    // Emoji button
                    Obx(
                      () => IconButton(
                        onPressed: () {
                          controller.toggleEmojiPicker();
                        },
                        icon: Icon(
                          controller.showEmojiPicker.value
                              ? Icons.keyboard
                              : Icons.emoji_emotions_outlined,
                          color: controller.showEmojiPicker.value
                              ? purple
                              : Colors.grey[600],
                          size: 22,
                        ),
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Send button dengan animasi
            Obx(() {
              final hasText = controller.textController.value.trim().isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasText ? purple : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: hasText
                      ? [
                          BoxShadow(
                            color: purple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: hasText
                        ? () => controller.sendMessage(
                            controller.textController.value,
                          )
                        : null,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper: avatar widget for AppBar
  Widget _contactAvatar(dynamic avatar) {
    final String? url = (avatar is String) ? avatar : null;
    final provider = _avatarProviderFromUrl(url);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.white.withOpacity(0.2),
      ),
      child: ClipOval(
        child: provider != null
            ? Image(image: provider, width: 40, height: 40, fit: BoxFit.cover)
            : const Icon(Icons.person, color: Colors.white, size: 24),
      ),
    );
  }

  // Resolve provider from possible URL or storage path
  ImageProvider<Object>? _avatarProviderFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return NetworkImage(url);
    if (url.startsWith('/')) return NetworkImage(url);
    return null;
  }

  // Helper: Check if avatar should be shown
  bool _shouldShowAvatar(
    Map<String, dynamic> msg,
    Map<String, dynamic>? prevMsg,
  ) {
    if (msg['fromMe'] == true) return false;
    if (prevMsg == null) return true;
    if (prevMsg['fromMe'] == true) return true;

    // Show avatar if there's a time gap
    final currentTime = _parseTime(msg['time']);
    final prevTime = _parseTime(prevMsg['time']);
    if (currentTime != null && prevTime != null) {
      return currentTime.difference(prevTime).inMinutes > 5;
    }

    return false;
  }

  // Helper: Check if timestamp should be shown
  bool _shouldShowTimestamp(
    Map<String, dynamic> msg,
    Map<String, dynamic>? prevMsg,
  ) {
    if (prevMsg == null) return true;

    final currentTime = _parseTime(msg['time']);
    final prevTime = _parseTime(prevMsg['time']);

    if (currentTime == null || prevTime == null) return false;

    // Show timestamp if messages are more than 15 minutes apart
    return currentTime.difference(prevTime).inMinutes > 15;
  }

  // Helper: Parse time string
  DateTime? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      return DateTime.parse(timeStr);
    } catch (_) {
      return null;
    }
  }

  // Helper: Format timestamp for separator
  String _formatTimestamp(String? timeStr) {
    final time = _parseTime(timeStr);
    if (time == null) return 'Now';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(time);
    if (diff.inDays == 1)
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    if (diff.inDays < 7) return DateFormat('EEEE HH:mm').format(time);

    return DateFormat('MMM dd, HH:mm').format(time);
  }

  // Helper: Format time for message bubble
  String _formatMessageTime(String? timeStr) {
    final time = _parseTime(timeStr);
    if (time == null) return '';
    return DateFormat('HH:mm').format(time);
  }

  // Show attachment options
  void _showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Share',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _attachmentOption(
              icon: Icons.image,
              label: 'Photos',
              color: Colors.purple,
              onTap: () => controller.pickImage(),
            ),
            _attachmentOption(
              icon: Icons.insert_drive_file,
              label: 'Documents',
              color: Colors.blue,
              onTap: () => controller.pickDocument(),
            ),
            _attachmentOption(
              icon: Icons.camera_alt,
              label: 'Camera',
              color: Colors.red,
              onTap: () => controller.pickCamera(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _attachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }

  // Show options menu
  void _showOptionsMenu() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Messages'),
              onTap: () {
                Get.back();
                controller.refreshMessages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Clear Chat',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                // Implement clear chat
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

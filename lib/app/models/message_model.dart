class MessageModel {
  final int? id;
  final int? conversationId;
  final int? senderId;
  final String text;
  final DateTime? createdAt;
  final bool? fromMe;
  final String? senderAvatar;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    required this.text,
    this.createdAt,
    this.fromMe,
    this.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Be lenient with keys (id, conversation_id, sender_id, text, created_at)
    DateTime? created;
    final rawCreated = json['created_at'] ?? json['time'];
    if (rawCreated is String) {
      try {
        created = DateTime.parse(rawCreated);
      } catch (_) {}
    }
    bool? fromMe;
    final rawFromMe = json['fromMe'] ?? json['from_me'] ?? json['is_me'];
    if (rawFromMe is bool) {
      fromMe = rawFromMe;
    } else if (rawFromMe is String) {
      fromMe = rawFromMe.toLowerCase() == 'true' || rawFromMe == '1';
    } else if (rawFromMe is int) {
      fromMe = rawFromMe == 1;
    }
    return MessageModel(
      id: _asInt(json['id']),
      conversationId: _asInt(
        json['conversation_id'] ?? json['room_id'] ?? json['conversationId'],
      ),
      senderId: _asInt(
        json['sender_id'] ?? json['user_id'] ?? json['senderId'],
      ),
      text: json['text']?.toString() ?? json['message']?.toString() ?? '',
      createdAt: created,
      fromMe: fromMe,
      senderAvatar: json['sender_avatar']?.toString(),
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) {
      return int.tryParse(v);
    }
    return null;
  }
}

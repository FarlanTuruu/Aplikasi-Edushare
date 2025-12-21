import 'package:get/get.dart';
import '../data/chat_repository.dart';
import '../data/api_client.dart';
import '../services/auth_service.dart';
import '../models/message_model.dart';

class MessagesService extends GetxService {
  late final ChatRepository _repo;
  late final ApiClient _apiClient;

  final messages = <MessageModel>[].obs;
  final currentRoomId = RxnInt();

  Future<MessagesService> init() async {
    _apiClient = ApiClient();
    _repo = ChatRepository(_apiClient);
    return this;
  }

  int? get _currentUserId {
    try {
      final auth = Get.find<AuthService>();
      return auth.user.value?['id'] as int?;
    } catch (_) {
      return null;
    }
  }

  Future<int?> ensureDmRoomWithUser(int userId) async {
    final res = await _repo.createOrGetDm(userId);
    // room id may be at data.id or top-level id
    final data = res['data'];
    int? roomId;
    if (data is Map<String, dynamic>) {
      roomId = _toInt(data['id']);
    }
    roomId ??= _toInt(res['id']);
    currentRoomId.value = roomId;
    return roomId;
  }

  Future<void> loadMessages(int roomId) async {
    currentRoomId.value = roomId;
    final list = await _repo.getMessages(roomId);
    final parsed = list.map((e) {
      if (e is Map<String, dynamic>) {
        return MessageModel.fromJson(e);
      }
      return MessageModel(text: e.toString());
    }).toList();
    messages.assignAll(parsed);
  }

  Future<MessageModel?> sendMessage(String text) async {
    final rid = currentRoomId.value;
    if (rid == null) return null;
    if (text.trim().isEmpty) return null;
    final res = await _repo.sendMessage(rid, text);
    // message may be at data or top-level
    Map<String, dynamic>? msgJson;
    if (res['data'] is Map<String, dynamic>) {
      msgJson = res['data'] as Map<String, dynamic>;
    } else if (res['message'] is Map<String, dynamic>) {
      msgJson = res['message'] as Map<String, dynamic>;
    } else if (res is Map<String, dynamic>) {
      msgJson = res;
    }
    final model = MessageModel.fromJson(msgJson ?? {'text': text});
    messages.add(model);
    return model;
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }
}

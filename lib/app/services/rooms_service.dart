import 'package:get/get.dart';
import '../data/rooms_repository.dart';
import '../data/api_client.dart';
import '../data/config.dart';

class RoomsService extends GetxService {
  late final RoomsRepository _repo;
  late final ApiClient _apiClient;
  final rooms = <Map<String, dynamic>>[].obs;

  Future<RoomsService> init() async {
    _apiClient = ApiClient();
    _repo = RoomsRepository(_apiClient);
    return this;
  }

  Future<void> loadRooms() async {
    final list = await _repo.getRooms();
    // Normalisasi struktur agar konsisten: id = conversation_id
    final parsed = list.map((e) {
      final m = Map<String, dynamic>.from(e is Map ? e : {});
      // Ambil conversation id dari beberapa kemungkinan field
      final convId =
          m['conversation_id'] ??
          (m['conversation'] is Map<String, dynamic>
              ? (m['conversation'] as Map<String, dynamic>)['id']
              : null) ??
          m['id'];
      // Ambil info user/peer untuk tampilan
      Map<String, dynamic>? user;
      for (final key in ['user', 'peer', 'other_user', 'participant']) {
        final v = m[key];
        if (v is Map<String, dynamic>) {
          user = v;
          break;
        }
      }
      // Resolve avatar URL to absolute, similar to homepage
      String? rawAvatar = (user != null ? user['avatar'] : m['avatar'])
          ?.toString();
      String? avatar = _resolveImageUrl(rawAvatar);
      final normalized = <String, dynamic>{
        'id': _asInt(convId),
        'conversation_id': _asInt(convId),
        'name': (user != null
            ? (user['name']?.toString() ?? '')
            : m['name']?.toString() ?? ''),
        'avatar': avatar,
        'user_id': _asInt(user != null ? user['id'] : m['user_id']),
        'status': m['status'] ?? '',
      };
      return normalized;
    }).toList();
    rooms.assignAll(parsed);
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    final base = apiBaseUrl;
    final host = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
    if (raw.startsWith('/')) return host + raw;
    if (raw.startsWith('storage/')) return '$host/$raw';
    return '$host/$raw';
  }
}

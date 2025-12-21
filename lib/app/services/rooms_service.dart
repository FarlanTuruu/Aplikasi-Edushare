import 'package:get/get.dart';
import '../data/rooms_repository.dart';
import '../data/api_client.dart';

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
    // Pastikan hasilnya list of map
    final parsed = list
        .map((e) => Map<String, dynamic>.from(e is Map ? e : {}))
        .toList();
    rooms.assignAll(parsed);
  }
}

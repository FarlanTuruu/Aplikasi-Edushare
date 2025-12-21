import 'package:get/get.dart';
import '../../../../services/rooms_service.dart';

class RoomsController extends GetxController {
  final searchQuery = ''.obs;
  final api = Get.put(RoomsService());
  final rooms = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await api.init();
    await api.loadRooms();
    rooms.assignAll(api.rooms);
    api.rooms.listen((val) => rooms.assignAll(val));
  }

  List<Map<String, dynamic>> get filteredRooms {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return rooms;
    return rooms
        .where((r) => (r['name'] ?? '').toString().toLowerCase().contains(q))
        .toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }
}

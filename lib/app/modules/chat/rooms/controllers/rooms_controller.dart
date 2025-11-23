import 'package:get/get.dart';

class RoomsController extends GetxController {
  final searchQuery = ''.obs;

  final rooms = [
    {'name': 'Nanda Adela', 'status': 'Seen 2h ago', 'avatar': 'assets/avatar.png'},
    {'name': 'Tegar Putra', 'status': 'Seen 16h ago', 'icon': 'mic'},
    {'name': 'Muh Farlan', 'status': '2d', 'icon': 'article'},
    {'name': 'Alfi Aulia', 'status': 'Sent', 'icon': 'group'},
  ].obs;

  List<Map<String, dynamic>> get filteredRooms {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return rooms;
    return rooms
        .where((r) => r['name'].toString().toLowerCase().contains(q))
        .toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }
}

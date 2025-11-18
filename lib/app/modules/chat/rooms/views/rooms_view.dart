import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/rooms_controller.dart';

class RoomsView extends GetView<RoomsController> {
  const RoomsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms View'), centerTitle: true),
      body: const Center(
        child: Text('Rooms View is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

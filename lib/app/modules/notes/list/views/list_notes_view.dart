import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/list_notes_controller.dart';

class ListNotesView extends GetView<ListNotesController> {
  const ListNotesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListNotesView'), centerTitle: true),
      body: const Center(
        child: Text('ListNotesView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

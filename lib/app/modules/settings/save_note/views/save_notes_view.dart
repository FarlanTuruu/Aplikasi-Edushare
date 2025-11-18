import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/save_notes_controller.dart';

class SaveNotesView extends GetView<SaveNotesController> {
  const SaveNotesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SaveNotesView'), centerTitle: true),
      body: const Center(
        child: Text('SaveNotesView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

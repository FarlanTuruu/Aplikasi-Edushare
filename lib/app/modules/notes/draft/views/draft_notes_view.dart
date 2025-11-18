import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/draft_notes_controller.dart';

class DraftNotesView extends GetView<DraftNotesController> {
  const DraftNotesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DraftNotesView'), centerTitle: true),
      body: const Center(
        child: Text(
          'DraftNotesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

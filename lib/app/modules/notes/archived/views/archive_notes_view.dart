import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/archive_notes_controller.dart';

class ArchiveNotesView extends GetView<ArchiveNotesController> {
  const ArchiveNotesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ArchiveNotesView'), centerTitle: true),
      body: const Center(
        child: Text(
          'ArchiveNotesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

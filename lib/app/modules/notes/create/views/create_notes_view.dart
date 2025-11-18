import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/create_notes_controller.dart';

class CreateNotesView extends GetView<CreateNotesController> {
  const CreateNotesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CreateNotesView'), centerTitle: true),
      body: const Center(
        child: Text(
          'CreateNotesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/scheduled_notes_controller.dart';

class ScheduledNotesView extends GetView<ScheduledNotesController> {
  const ScheduledNotesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScheduledNotesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ScheduledNotesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

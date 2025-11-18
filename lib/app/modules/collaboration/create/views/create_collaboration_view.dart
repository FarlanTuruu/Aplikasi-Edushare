import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/create_collaboration_controller.dart';

class CreateCollaborationView extends GetView<CreateCollaborationController> {
  const CreateCollaborationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create CollaborationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Create CollaborationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

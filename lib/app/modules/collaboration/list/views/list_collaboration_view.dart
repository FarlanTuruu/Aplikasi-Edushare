import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/list_collaboration_controller.dart';

class ListCollaborationView extends GetView<ListCollaborationController> {
  const ListCollaborationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListCollaborationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ListCollaborationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

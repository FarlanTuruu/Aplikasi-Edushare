import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detail_collaboration_controller.dart';

class DetailCollaborationView extends GetView<DetailCollaborationController> {
  const DetailCollaborationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailCollaborationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DetailCollaborationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

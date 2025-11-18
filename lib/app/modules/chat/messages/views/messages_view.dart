import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/messages_controller.dart';

class MessagesView extends GetView<MessagesController> {
  const MessagesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MessagesView'), centerTitle: true),
      body: const Center(
        child: Text('MessagesView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

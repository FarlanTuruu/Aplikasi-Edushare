import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/list_speech_controller.dart';

class ListSpeechView extends GetView<ListSpeechController> {
  const ListSpeechView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListSpeechView'), centerTitle: true),
      body: const Center(
        child: Text(
          'ListSpeechView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

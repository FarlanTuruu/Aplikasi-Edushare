import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/trash_speech_controller.dart';

class TrashSpeechView extends GetView<TrashSpeechController> {
  const TrashSpeechView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrashSpeechView'), centerTitle: true),
      body: const Center(
        child: Text(
          'TrashSpeechView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

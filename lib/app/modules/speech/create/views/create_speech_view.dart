import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/create_speech_controller.dart';

class CreateSpeechView extends GetView<CreateSpeechController> {
  const CreateSpeechView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CreateSpeechView'), centerTitle: true),
      body: const Center(
        child: Text(
          'CreateSpeechView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

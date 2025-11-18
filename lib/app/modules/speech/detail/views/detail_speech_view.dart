import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/detail_speech_controller.dart';

class DetailSpeechView extends GetView<DetailSpeechController> {
  const DetailSpeechView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DetailSpeechView'), centerTitle: true),
      body: const Center(
        child: Text(
          'DetailSpeechView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

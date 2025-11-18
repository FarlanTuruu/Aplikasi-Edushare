import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_settings_controller.dart';

class ProfileSettingsView extends GetView<ProfileSettingsController> {
  const ProfileSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProfileSettingsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ProfileSettingsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

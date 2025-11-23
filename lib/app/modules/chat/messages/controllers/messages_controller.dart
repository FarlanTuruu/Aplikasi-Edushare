import 'package:get/get.dart';

class MessagesController extends GetxController {
  final messages = <Map<String, dynamic>>[
    {'fromMe': false, 'text': 'Free tonight?👀', 'time': '12:42 PM'},
    {'fromMe': true, 'text': 'Yeah, I think so!'},
    {'fromMe': true, 'text': 'What you wanna do?'},
    {'fromMe': false, 'text': 'Hmm.. movies?'},
    {'fromMe': true, 'text': 'Sounds good! I can meet after 6.'},
    {'fromMe': true, 'text': 'Bit busy til then...😁'},
    {'fromMe': false, 'text': 'Sounds good! What you up to now?'},
  ].obs;

  final textController = ''.obs;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add({'fromMe': true, 'text': text});
    textController.value = '';
  }
}

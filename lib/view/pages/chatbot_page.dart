import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = InMemoryChatController();
    return Scaffold(
      appBar: AppBar(title: Text('Chatbot page')),
      body: Chat(
        currentUserId: 'userID',
        chatController: chatController,
        onMessageSend: (text) {
          //run insert message method from chatController
          chatController.insertMessage(
            TextMessage(
              id: Uuid().v4(),
              authorId: 'userID',
              text: text,
              createdAt: DateTime.timestamp(),
            ),
          );
        },
        resolveUser: (UserID id) async {
          return User(id: id, name: 'John');
        },
      ),
    );
  }
}

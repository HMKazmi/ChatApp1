import 'package:chat_app1/view/widgets/messages.dart';
import 'package:chat_app1/view/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        title: Text(
          'FlutterChat',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ), 
      body: Column(
        children: [
          Expanded(
            child: Messages(),
          ),
          const NewMessage(), // This widget will stay at the bottom of the screen
        ],
      ),
    );
  }
}
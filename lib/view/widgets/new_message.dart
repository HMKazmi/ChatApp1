  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';

  class NewMessage extends StatefulWidget {
    const NewMessage({super.key});

    @override
    State<NewMessage> createState() => _NewMessageState();
  }

  class _NewMessageState extends State<NewMessage> {
    final messagesController = TextEditingController();
    
    @override
    void dispose() {
      messagesController.dispose();
      super.dispose();
    }

    // Helper function to extract username from email
    String _getUsernameFromEmail(String email) {
      return email.split('@')[0];
    }

    void _submitMessage() async {
      final message = messagesController.text;
      if (message.trim().isEmpty) {
        return;
      }
      
      FocusScope.of(context).unfocus();
      messagesController.clear();
      
      final user = FirebaseAuth.instance.currentUser!;
      
      // Try to get user data from Firestore
      String username;
      String? imageUrl;
      
      try {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userData.exists && userData.data() != null) {
          // Use data from Firestore if available
          username = userData.data()!['username'] ?? _getUsernameFromEmail(user.email ?? 'user@example.com');
          imageUrl = userData.data()!['image_url'];
        } else {
          // If no data in Firestore, extract username from email
          username = _getUsernameFromEmail(user.email ?? 'user@example.com');
          imageUrl = null;
        }
      } catch (e) {
        // In case of error, fall back to email-based username
        username = _getUsernameFromEmail(user.email ?? 'user@example.com');
        imageUrl = null;
      }
      
      // Add message to Firestore
      await FirebaseFirestore.instance.collection('chat').add({
        'text': message,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': username,
        'image_url': imageUrl,
      });
    }

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 1,
          bottom: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autocorrect: true,
                textCapitalization: TextCapitalization.sentences,
                controller: messagesController,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  labelText: "Type a message here",
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitMessage,
            )
          ],
        ),
      );
    }
  }
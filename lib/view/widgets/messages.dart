import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app1/view/widgets/message_bubble.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class Messages extends StatelessWidget {
  const Messages({super.key});



  // Helper function to extract username from email
  String _getUsernameFromEmail(String email) {
    return email.split('@')[0];
  }
  
  // Format timestamp to readable format
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  // Delete message handler
  Future<void> _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance.collection('chat').doc(messageId).delete();
  }

  // Edit message handler
  Future<void> _editMessage(BuildContext context, String messageId, String currentText) async {
    final TextEditingController editController = TextEditingController(text: currentText);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Edit your message',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('chat').doc(messageId).update({
                  'text': editController.text.trim(),
                  'edited': true,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show menu for message options
  void _showMessageOptions(BuildContext context, bool isMe, String messageId, String currentText, String messageType) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (messageType == 'text') {
                    _editMessage(context, messageId, currentText);
                  }
                },
                enabled: messageType == 'text', // Only allow editing text messages
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(messageId);
                },
              ),
            ],
            if (!isMe)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Message Info'),
                onTap: () {
                  Navigator.pop(ctx);
                  // Show message info if needed
                },
              ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {

    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    // print("authenticatedUser.email");
    // print(authenticatedUser.email);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text(
              'Error occurred while loading chats.',
            ),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No chats found',
            ),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final messageId = loadedMessages[index].id;
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage['userId']
                : null;

            // Display username from data or extract from email if not available
            String displayUsername = chatMessage['username'] ?? 
                _getUsernameFromEmail(authenticatedUser.email ?? 'user@example.com');
                
            final messageTimestamp = chatMessage['createdAt'] as Timestamp;
            final formattedTime = _formatTimestamp(messageTimestamp);
            final isEdited = chatMessage['edited'] == true;
            final messageType = chatMessage['type'] ?? 'text';
            final isMe = authenticatedUser.uid == currentMessageUserId;
            final nextUserIsSame = currentMessageUserId == nextMessageUserId;

            return GestureDetector(
              onLongPress: () {
                _showMessageOptions(
                  context, 
                  isMe, 
                  messageId, 
                  chatMessage['text'] ?? '', 
                  messageType
                );
              },
              child: nextUserIsSame
                ? MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: isMe,
                    imageUrl: messageType == 'image' ? chatMessage['imageUrl'] : null,
                    messageType: messageType,
                    timeStamp: formattedTime,
                    isEdited: isEdited,
                  )
                : MessageBubble.first(
                    username: displayUsername,
                    message: chatMessage['text'],
                    isMe: isMe,
                    imageUrl: messageType == 'image' ? chatMessage['imageUrl'] : null,
                    messageType: messageType,
                    timeStamp: formattedTime,
                    isEdited: isEdited,
                  ),
            );
          }
        );
      },
    );
  }
}
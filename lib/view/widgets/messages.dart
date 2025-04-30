import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app1/view/widgets/message_bubble.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class Messages extends StatelessWidget {
  const Messages({super.key});

  Future<void> createSampleChatMessages() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference chatCollection = firestore.collection('chat');
    
    // Check if the collection already has messages
    final snapshot = await chatCollection.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Chat collection already has messages. Skipping sample creation.');
      return;
    }
    
    // Current user info
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid ?? 'sampleCurrentUser';
    final currentUserEmail = currentUser?.email ?? 'current@example.com';
    final currentUsername = currentUserEmail.split('@')[0];
    
    // Sample other user
    const otherUserId = 'sampleOtherUser123';
    const otherUsername = 'alice';
    
    // Create sample messages
    final sampleMessages = [
      {
        'text': 'Hello! Welcome to the chat app!',
        'userId': otherUserId,
        'username': otherUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
        'type': 'text', // Adding message type
      },
      {
        'text': 'Thanks! This is my first message.',
        'userId': currentUserId,
        'username': currentUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 25))),
        'type': 'text',
      },
      {
        'text': 'How are you finding the app so far?',
        'userId': otherUserId,
        'username': otherUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 20))),
        'type': 'text',
      },
      {
        'text': 'Pretty good! The UI is clean and responsive.',
        'userId': currentUserId,
        'username': currentUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 15))),
        'type': 'text',
      },
      {
        'text': 'Can we add more features like image sharing?',
        'userId': currentUserId,
        'username': currentUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 10))),
        'type': 'text',
      },
      {
        'text': 'Absolutely! That\'s coming in the next update.',
        'userId': otherUserId,
        'username': otherUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 8))),
        'type': 'text',
      },
      {
        'text': 'Great to hear that! Looking forward to it.',
        'userId': currentUserId,
        'username': currentUsername,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5))),
        'type': 'text',
      },
    ];
    
    // Add messages to Firestore
    for (final message in sampleMessages) {
      await chatCollection.add(message);
    }
    
    print('Sample chat messages created successfully!');
  }

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
    createSampleChatMessages();

    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    print("authenticatedUser.email");
    print(authenticatedUser.email);
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
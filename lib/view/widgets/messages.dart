import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app1/view/widgets/message_bubble.dart';

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
      'userId': otherUserId, // Note: your code has 'userId' not 'userId'
      'username': otherUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'text': 'Thanks! This is my first message.',
      'userId': currentUserId,
      'username': currentUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'text': 'How are you finding the app so far?',
      'userId': otherUserId,
      'username': otherUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'text': 'Pretty good! The UI is clean and responsive.',
      'userId': currentUserId,
      'username': currentUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'text': 'Can we add more features like image sharing?',
      'userId': currentUserId,
      'username': currentUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'text': 'Absolutely! That\'s coming in the next update.',
      'userId': otherUserId,
      'username': otherUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
    },
    {
      'text': 'Great to hear that! Looking forward to it.',
      'userId': currentUserId,
      'username': currentUsername,
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5))),
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
  
  @override
  Widget build(BuildContext context) {
      createSampleChatMessages();

    final authenticatedUser = FirebaseAuth.instance.currentUser!;
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
          print(chatSnapshot.connectionState);
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

            final nextUserIsSame = currentMessageUserId == nextMessageUserId;

            print("authenticatedUser.uid");
            print(authenticatedUser.uid);
            print("currentMessageUserId");
            print(currentMessageUserId);
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              ); 
            } else {
              return MessageBubble.first(
                username: displayUsername,
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId
              ); 
            }
          }
        );
      },
    );
  }
}
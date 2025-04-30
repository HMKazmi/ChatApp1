import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.message,
    required this.isMe,
    required this.username,
    this.imageUrl,
    required this.messageType,
    required this.timeStamp,
    this.isEdited = false,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    this.imageUrl,
    required this.messageType,
    required this.timeStamp,
    this.isEdited = false,
  })  : isFirstInSequence = false,
        username = '';

  final bool isFirstInSequence;
  final String message;
  final bool isMe;
  final String username;
  final String? imageUrl;
  final String messageType;
  final String timeStamp;
  final bool isEdited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) 
            const SizedBox(width: 15),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isFirstInSequence)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 13,
                      right: 13,
                    ),
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                
                Container(
                  decoration: BoxDecoration(
                    color: isMe
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary.withAlpha(200),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: !isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(12),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(12),
                    ),
                  ),
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (messageType == 'text')
                        Text(
                          message,
                          style: TextStyle(
                            height: 1.3,
                            color: isMe
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSecondary,
                          ),
                          softWrap: true,
                        ),
                      
                      if (messageType == 'image' && imageUrl != null)
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            timeStamp,
                            style: TextStyle(
                              fontSize: 12,
                              color: isMe
                                  ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                  : theme.colorScheme.onSecondary.withOpacity(0.7),
                            ),
                          ),
                          if (isEdited)
                            Text(
                              ' (edited)',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: isMe
                                    ? theme.colorScheme.onPrimary.withOpacity(0.7)
                                    : theme.colorScheme.onSecondary.withOpacity(0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isMe) 
            const SizedBox(width: 15),
        ],
      ),
    );
  }
}
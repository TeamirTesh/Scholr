import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scholr/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.isMe});
  final ChatMessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.senderName, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(message.text),
            if (message.fileUrl != null && message.fileUrl!.isNotEmpty)
              TextButton(onPressed: () {}, child: const Text('Open file link shared in chat')),
            Text(DateFormat('h:mm a').format(message.timestamp), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

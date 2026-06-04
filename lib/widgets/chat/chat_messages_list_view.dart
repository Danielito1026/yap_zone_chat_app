import 'package:flutter/material.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/models/chat_message.dart';
import 'package:yap_zone/widgets/chat/chat_message_bubble.dart';

class ChatMessagesListView extends StatelessWidget {
  const ChatMessagesListView({
    super.key,
    required this.chat,
    required this.messages,
  });
  final Chat chat;
  final List<ChatMessage> messages;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true, // newest at bottom
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // get current message
        final message = messages[index];
        // check if there is a next message
        final nextMessage = index + 1 < messages.length
            ? messages[index + 1]
            : null;

        // get sender user data
        final senderData = chat.members.firstWhere(
          (user) => user.uid == message.senderId,
        );

        // get current message sender id
        final currentMessageUserId = message.senderId;
        // get next message sender id
        final nextMessageUserId = nextMessage?.senderId;

        // if next message is not null use the message bubble next
        final nextUserIsSame = currentMessageUserId == nextMessageUserId;

        if (nextUserIsSame) {
          return ChatMessageBubble.next(
            type: message.type,
            message: message.content,
            isMe: message.senderId == chat.currentUserId,
            sendTime: message.timestamp,
          );
        }
        return ChatMessageBubble.first(
          userImage: senderData.imageUrl,
          username: senderData.username,
          type: message.type,
          message: message.content,
          isMe: message.senderId == chat.currentUserId,
          sendTime: message.timestamp,
        );
      },
    );
  }
}

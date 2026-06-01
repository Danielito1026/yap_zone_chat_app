import 'package:flutter/material.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/widgets/chat/chat_list_item.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key, required this.chats});

  final List<Chat> chats;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ChatListItem(
          title: chats[index].displayName,
          subtitle: chats[index].messages.length > 0
              ? chats[index].messages.last.content
              : 'No messages yet',
          avatarUrl: chats[index].displayImage,
          isActive: chats[index].isActive,
          isGroupChat: chats[index].isGroupChat,
          isActivity: chats[index].isActive,
          onTap: () {
            // Navigate to chat page
          },
        );
      },
    );
  }
}

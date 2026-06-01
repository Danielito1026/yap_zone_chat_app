import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/providers/chat_provider.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key, required this.chat});

  final Chat chat;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(chat.uid));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: chat.displayImage.startsWith('assets')
                  ? AssetImage(chat.displayImage) as ImageProvider
                  : NetworkImage(chat.displayImage),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(chat.displayName),
          ],
        ),
      ),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(child: Text('No messages yet. Say hi!'));
          }
          return ListView.builder(
            reverse: true, // newest at bottom
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMe = message.senderId == chat.currentUserId;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceDim,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(message.content),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

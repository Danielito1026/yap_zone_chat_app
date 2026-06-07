import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/chat.dart';
import 'package:yap_zone/providers/chat_provider.dart';
import 'package:yap_zone/providers/navigator_provider.dart';
import 'package:yap_zone/widgets/chat/chat_message_bar.dart';
import 'package:yap_zone/widgets/chat/chat_messages_list_view.dart';
import 'package:yap_zone/widgets/rounded_image_avatar.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.chat});

  final Chat chat;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  void _onConfirmLeaveChat(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
    await ref.read(chatActionProvider.notifier).leaveChat(widget.chat);
    ref.read(navigationServiceProvider).goBack();
  }

  void _onLeaveChat() {
    final title = 'Leave chat with ${widget.chat.displayName}?';
    final content =
        'This action cannot be undone. It will permanently remove you from the chat with ${widget.chat.displayName} and all associated data.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () => _onConfirmLeaveChat(context),
              child: Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesV2Provider(widget.chat.uid));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 20, 20, 24),
        title: Row(
          children: [
            RoundedImageAvatar(
              avatarUrl: widget.chat.displayImage,
              isActive: widget.chat.isActive,
              isGroupChat: widget.chat.isGroupChat,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.chat.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _onLeaveChat,
            icon: Icon(Icons.directions_walk),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }
                return ChatMessagesListView(
                  chat: widget.chat,
                  messages: messages,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          ChatMessageBar(chatId: widget.chat.uid),
        ],
      ),
    );
  }
}

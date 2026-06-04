import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/chat_provider.dart';
import 'package:yap_zone/widgets/chat/chat_list_view.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {


  @override
  Widget build(BuildContext context) {
    final userChatsAsync =  ref.watch(userChatsV2Provider);
    return userChatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return Center(child: Text('No chats yet. Start a conversation!'),);
        }
        return ChatListView(chats: chats);
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading chats:\n$e')),
    );
  }
}

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
    final userChatsAsync = ref.watch(userChatsV2Provider);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(userChatsV2Provider),
      child: Center(
        child: userChatsAsync.when(
          data: (chats) {
            if (chats.isEmpty) {
              return Text('No chats yet...');
            }
            return ChatListView(chats: chats);
          },
          error: (e, st) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error loading chats'),
              TextButton(
                onPressed: () => ref.refresh(userChatsV2Provider),
                child: Text('Retry'),
              ),
            ],
          ),
          loading: () => CircularProgressIndicator(),
        ),
      ),
    );
  }
}

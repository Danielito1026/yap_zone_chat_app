import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/providers/chat_provider.dart';
import 'package:yap_zone/providers/user_provider.dart';
import 'package:yap_zone/routes/router.dart';
import 'package:yap_zone/widgets/users/user_list_item.dart';

class UserListView extends ConsumerStatefulWidget {
  const UserListView({super.key, required this.users});
  final List<UserModel> users;

  @override
  ConsumerState<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends ConsumerState<UserListView> {
  Future<void> _onCreateChat() async {
    final chatId = await ref.read(userActionProvider.notifier).createChat();
    final chat = await ref.read(chatServiceV2Provider).getChatById(chatId!);
    if (chat != null && mounted) {
      AppRoutes.openChat(context, chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAction = ref.watch(userActionProvider);

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16),
          itemCount: widget.users.length,
          itemBuilder: (ctx, index) => UserListItem(
            image: widget.users[index].imageUrl,
            isActive: true,
            username: widget.users[index].username,
            email: widget.users[index].email,
            onTap: () {
              final user = widget.users[index];
              if (userAction.contains(user)) {
                ref.read(userActionProvider.notifier).removeUser(user.uid);
              } else {
                ref.read(userActionProvider.notifier).setUsers(user);
              }
            },
            isSelected: userAction.contains(widget.users[index]),
          ),
        ),

        if (userAction.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: FilledButton(
              onPressed: _onCreateChat,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                userAction.length == 1
                    ? 'Create chat with ${userAction.first.username}'
                    : 'Create group with ${userAction.length} users',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

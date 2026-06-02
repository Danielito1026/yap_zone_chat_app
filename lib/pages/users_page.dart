import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/user_provider.dart';
import 'package:yap_zone/widgets/users/user_list_view.dart';
import 'package:yap_zone/widgets/users/user_search_bar.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(usersProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          UserSearchBar(),
          // if (users.isEmpty) Center(child: Text('No other users around..')),
          // Expanded(child: UserListView(users: users)),
          userAsync.when(
            data: (users) {
              if (users.isEmpty)
                return Center(child: Text('No users around...'));
              return UserListView(users: users);
            },
            error: (e, st) => Center(child: Text('Some Error occurred: ${e.toString()}',softWrap: true,)),
            loading: () => CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

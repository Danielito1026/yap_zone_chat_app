import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/providers/user_provider.dart';
import 'package:yap_zone/widgets/users/user_list_view.dart';
import 'package:yap_zone/widgets/users/user_search_bar.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({super.key});

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  List<UserModel> _filterUsers(List<UserModel> users, String query) {
    if (query.isEmpty) return users;

    return users
        .where(
          (user) =>
              user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.name.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(usersProvider);
    final query = ref.watch(searchQueryProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 16,
        children: [
          UserSearchBar(),
          userAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return Center(child: Text('No users around...'));
              }
              return Expanded(
                child: UserListView(users: _filterUsers(users, query)),
              );
            },
            error: (e, st) => Column(
              children: [
                Text('Error loading users'),
                TextButton(
                  onPressed: () => ref.refresh(usersProvider),
                  child: Text('Retry'),
                ),
              ],
            ),
            loading: () => CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

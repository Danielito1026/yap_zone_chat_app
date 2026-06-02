import 'package:flutter/material.dart';
import 'package:yap_zone/models/user.dart';
import 'package:yap_zone/widgets/users/user_list_item.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key, required this.users});
  final List<UserModel> users;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      itemCount: users.length,
      itemBuilder: (ctx, index) => UserListItem(
        image: users[index].imageUrl,
        isActive: true,
        username: users[index].username,
        email: users[index].email,
        onTap: () {},
      ),
    );
  }
}

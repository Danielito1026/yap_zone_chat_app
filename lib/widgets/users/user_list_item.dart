import 'package:flutter/material.dart';
import 'package:yap_zone/widgets/rounded_image_avatar.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.image,
    required this.isActive,
    required this.username,
    required this.email,
    required this.onTap,
  });

  final String image;
  final bool isActive;
  final String username;
  final String email;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: RoundedImageAvatar(avatarUrl: image, isActive: isActive),
      title: Text(
        username,
        style: TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

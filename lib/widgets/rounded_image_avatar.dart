import 'package:flutter/material.dart';

class RoundedImageAvatar extends StatelessWidget {
  const RoundedImageAvatar({super.key
  ,
  this.avatarUrl = 'https://example.com/avatar.jpg',
  this.isGroupChat = false,
  this.isActive = false,});

  final String avatarUrl;
  final bool isGroupChat;
  final bool isActive; // Set to true for active users

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: isGroupChat
          ? AssetImage(avatarUrl)
          : NetworkImage(avatarUrl),
      radius: 25,
      child: isActive
          ? Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            )
          : null,
    );
  }
}

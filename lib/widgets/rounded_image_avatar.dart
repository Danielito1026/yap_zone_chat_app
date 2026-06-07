import 'package:flutter/material.dart';

class RoundedImageAvatar extends StatelessWidget {
  const RoundedImageAvatar({
    super.key,
    this.avatarUrl = 'https://example.com/avatar.jpg',
    this.isGroupChat = false,
    this.isActive = false,
    this.radius = 25,
    this.indicatorSize = 12,
  });

  final String avatarUrl;
  final bool isGroupChat;
  final bool isActive;
  final double radius;
  final double indicatorSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: isGroupChat
          ? AssetImage(avatarUrl)
          : NetworkImage(avatarUrl),
      radius: radius,
      child: isActive
          ? Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
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

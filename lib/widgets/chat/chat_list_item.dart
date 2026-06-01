import 'package:flutter/material.dart';
import 'package:yap_zone/widgets/rounded_image_avatar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarUrl,
    required this.isActive,
    required this.isGroupChat,
    required this.isActivity,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String avatarUrl;
  final bool isActive;
  final bool isGroupChat;
  final bool isActivity;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: RoundedImageAvatar(
        avatarUrl: avatarUrl,
        isActive: isActive,
        isGroupChat: isGroupChat,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: isActivity
          ? Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 4),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[900],
                  ),
                  child: SpinKitThreeBounce(color: Colors.white, size: 12),
                ),
              ],
            )
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
